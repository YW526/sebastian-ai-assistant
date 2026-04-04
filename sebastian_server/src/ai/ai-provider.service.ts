import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AiConfig } from './ai-config.entity';
import { AiUsage } from './ai-usage.entity';

export type AiChatMessage = {
  role: 'system' | 'user' | 'assistant';
  content: string;
};

export interface AiChatResult {
  text: string;
  inputTokens: number;
  outputTokens: number;
  costUsd: number;
}

/** USD per 1 M tokens */
export const MODEL_PRICING: Record<
  string,
  { input: number; output: number }
> = {
  // Claude
  'claude-sonnet-4-20250514': { input: 3, output: 15 },
  'claude-opus-4-20250514': { input: 15, output: 75 },
  'claude-haiku-4-5-20251001': { input: 0.8, output: 4 },
  // OpenAI
  'gpt-4o': { input: 2.5, output: 10 },
  'gpt-4o-mini': { input: 0.15, output: 0.6 },
  'gpt-4-turbo': { input: 10, output: 30 },
  'o4-mini': { input: 1.1, output: 4.4 },
  // Gemini
  'gemini-2.5-flash': { input: 0.15, output: 0.6 },
  'gemini-2.5-pro': { input: 1.25, output: 10 },
  'gemini-2.0-flash': { input: 0.1, output: 0.4 },
};

const DEFAULT_MODELS: Record<string, string> = {
  claude: 'claude-sonnet-4-20250514',
  openai: 'gpt-4o-mini',
  gemini: 'gemini-2.0-flash',
};

@Injectable()
export class AiProviderService {
  private readonly logger = new Logger(AiProviderService.name);

  constructor(
    @InjectRepository(AiConfig)
    private readonly configRepo: Repository<AiConfig>,
    @InjectRepository(AiUsage)
    private readonly usageRepo: Repository<AiUsage>,
    private readonly env: ConfigService,
  ) {}

  private get timeoutMs(): number {
    return Number(this.env.get<string>('AI_TIMEOUT_MS') ?? '120000');
  }

  /** 활성 프로바이더 설정 조회 */
  async getActiveConfig(): Promise<AiConfig | null> {
    return this.configRepo.findOne({ where: { isActive: true } });
  }

  /** 채팅 요청 — 활성 프로바이더로 라우팅 */
  async chat(
    messages: AiChatMessage[],
    userId?: number,
  ): Promise<AiChatResult> {
    const config = await this.getActiveConfig();
    if (!config || !config.apiKey) {
      throw new Error(
        'AI 설정이 없습니다. 설정 화면에서 프로바이더와 API 키를 입력해 주세요.',
      );
    }

    let result: AiChatResult;
    switch (config.provider) {
      case 'claude':
        result = await this.callClaude(config, messages);
        break;
      case 'openai':
        result = await this.callOpenAI(config, messages);
        break;
      case 'gemini':
        result = await this.callGemini(config, messages);
        break;
      default:
        throw new Error(`지원하지 않는 프로바이더: ${config.provider}`);
    }

    if (userId) {
      await this.recordUsage(
        userId,
        config.provider,
        config.model,
        result.inputTokens,
        result.outputTokens,
      );
    }

    return result;
  }

  /* ───── Claude ───── */

  private async callClaude(
    config: AiConfig,
    messages: AiChatMessage[],
  ): Promise<AiChatResult> {
    const systemMsg = messages.find((m) => m.role === 'system');
    const chatMsgs = messages.filter((m) => m.role !== 'system');

    const body: Record<string, unknown> = {
      model: config.model,
      max_tokens: 4096,
      messages: chatMsgs.map((m) => ({ role: m.role, content: m.content })),
    };
    if (systemMsg) {
      body.system = systemMsg.content;
    }

    const res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': config.apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(this.timeoutMs),
    });

    const raw = await res.text();
    if (!res.ok) {
      const errMsg = this.parseErrorMessage(raw) ?? `HTTP ${res.status}`;
      throw new Error(`Claude 오류: ${errMsg}`);
    }

    const data = JSON.parse(raw);
    const text =
      data.content
        ?.filter((b: { type: string }) => b.type === 'text')
        .map((b: { text: string }) => b.text)
        .join('') ?? '';
    const usage = data.usage;

    return {
      text: text.trim(),
      inputTokens: usage?.input_tokens ?? 0,
      outputTokens: usage?.output_tokens ?? 0,
      costUsd: this.calcCost(
        config.model,
        usage?.input_tokens ?? 0,
        usage?.output_tokens ?? 0,
      ),
    };
  }

  /* ───── OpenAI ───── */

  private async callOpenAI(
    config: AiConfig,
    messages: AiChatMessage[],
  ): Promise<AiChatResult> {
    const res = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${config.apiKey}`,
      },
      body: JSON.stringify({
        model: config.model,
        messages: messages.map((m) => ({ role: m.role, content: m.content })),
      }),
      signal: AbortSignal.timeout(this.timeoutMs),
    });

    const raw = await res.text();
    if (!res.ok) {
      const errMsg = this.parseErrorMessage(raw) ?? `HTTP ${res.status}`;
      throw new Error(`OpenAI 오류: ${errMsg}`);
    }

    const data = JSON.parse(raw);
    const text = data.choices?.[0]?.message?.content ?? '';
    const usage = data.usage;

    return {
      text: text.trim(),
      inputTokens: usage?.prompt_tokens ?? 0,
      outputTokens: usage?.completion_tokens ?? 0,
      costUsd: this.calcCost(
        config.model,
        usage?.prompt_tokens ?? 0,
        usage?.completion_tokens ?? 0,
      ),
    };
  }

  /* ───── Gemini ───── */

  private async callGemini(
    config: AiConfig,
    messages: AiChatMessage[],
  ): Promise<AiChatResult> {
    const systemMsg = messages.find((m) => m.role === 'system');
    const chatMsgs = messages.filter((m) => m.role !== 'system');

    const contents = chatMsgs.map((m) => ({
      role: m.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: m.content }],
    }));

    const body: Record<string, unknown> = { contents };
    if (systemMsg) {
      body.systemInstruction = { parts: [{ text: systemMsg.content }] };
    }

    const url = `https://generativelanguage.googleapis.com/v1beta/models/${config.model}:generateContent?key=${config.apiKey}`;
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(this.timeoutMs),
    });

    const raw = await res.text();
    if (!res.ok) {
      const errMsg = this.parseErrorMessage(raw) ?? `HTTP ${res.status}`;
      throw new Error(`Gemini 오류: ${errMsg}`);
    }

    const data = JSON.parse(raw);
    const text =
      data.candidates?.[0]?.content?.parts?.[0]?.text ?? '';
    const meta = data.usageMetadata;

    return {
      text: text.trim(),
      inputTokens: meta?.promptTokenCount ?? 0,
      outputTokens: meta?.candidatesTokenCount ?? 0,
      costUsd: this.calcCost(
        config.model,
        meta?.promptTokenCount ?? 0,
        meta?.candidatesTokenCount ?? 0,
      ),
    };
  }

  /* ───── 비용 계산 ───── */

  private calcCost(
    model: string,
    inputTokens: number,
    outputTokens: number,
  ): number {
    const p = MODEL_PRICING[model];
    if (!p) return 0;
    return (inputTokens * p.input + outputTokens * p.output) / 1_000_000;
  }

  /* ───── 사용량 기록 ───── */

  async recordUsage(
    userId: number,
    provider: string,
    model: string,
    inputTokens: number,
    outputTokens: number,
  ): Promise<void> {
    const costUsd = this.calcCost(model, inputTokens, outputTokens);
    const row = this.usageRepo.create({
      userId,
      provider,
      model,
      inputTokens,
      outputTokens,
      costUsd,
    });
    await this.usageRepo.save(row);
  }

  /* ───── 사용량 조회 ───── */

  async getUsageSummary(
    userId: number,
    days?: number,
  ): Promise<{
    totalCostUsd: number;
    totalInputTokens: number;
    totalOutputTokens: number;
    totalRequests: number;
    byProvider: Record<
      string,
      { costUsd: number; inputTokens: number; outputTokens: number; requests: number }
    >;
    byModel: Record<
      string,
      { costUsd: number; inputTokens: number; outputTokens: number; requests: number }
    >;
    daily: { date: string; costUsd: number; requests: number }[];
  }> {
    let qb = this.usageRepo
      .createQueryBuilder('u')
      .where('u.userId = :userId', { userId });

    if (days && days > 0) {
      const from = new Date();
      from.setDate(from.getDate() - days);
      qb = qb.andWhere('u.createdAt >= :from', { from: from.toISOString() });
    }

    const rows = await qb.orderBy('u.createdAt', 'ASC').getMany();

    let totalCostUsd = 0;
    let totalInputTokens = 0;
    let totalOutputTokens = 0;

    const byProvider: Record<
      string,
      { costUsd: number; inputTokens: number; outputTokens: number; requests: number }
    > = {};
    const byModel: Record<
      string,
      { costUsd: number; inputTokens: number; outputTokens: number; requests: number }
    > = {};
    const dailyMap: Record<string, { costUsd: number; requests: number }> = {};

    for (const r of rows) {
      totalCostUsd += r.costUsd;
      totalInputTokens += r.inputTokens;
      totalOutputTokens += r.outputTokens;

      if (!byProvider[r.provider]) {
        byProvider[r.provider] = {
          costUsd: 0,
          inputTokens: 0,
          outputTokens: 0,
          requests: 0,
        };
      }
      byProvider[r.provider].costUsd += r.costUsd;
      byProvider[r.provider].inputTokens += r.inputTokens;
      byProvider[r.provider].outputTokens += r.outputTokens;
      byProvider[r.provider].requests++;

      if (!byModel[r.model]) {
        byModel[r.model] = {
          costUsd: 0,
          inputTokens: 0,
          outputTokens: 0,
          requests: 0,
        };
      }
      byModel[r.model].costUsd += r.costUsd;
      byModel[r.model].inputTokens += r.inputTokens;
      byModel[r.model].outputTokens += r.outputTokens;
      byModel[r.model].requests++;

      const date = r.createdAt.toISOString().slice(0, 10);
      if (!dailyMap[date]) {
        dailyMap[date] = { costUsd: 0, requests: 0 };
      }
      dailyMap[date].costUsd += r.costUsd;
      dailyMap[date].requests++;
    }

    const daily = Object.entries(dailyMap)
      .map(([date, v]) => ({ date, ...v }))
      .sort((a, b) => a.date.localeCompare(b.date))
      .slice(-30);

    return {
      totalCostUsd,
      totalInputTokens,
      totalOutputTokens,
      totalRequests: rows.length,
      byProvider,
      byModel,
      daily,
    };
  }

  async clearUsage(userId: number): Promise<void> {
    await this.usageRepo.delete({ userId });
  }

  /** 프로바이더 · 모델 목록 */
  getProviders(): {
    provider: string;
    label: string;
    models: { id: string; name: string }[];
  }[] {
    return [
      {
        provider: 'claude',
        label: 'Anthropic Claude',
        models: [
          { id: 'claude-sonnet-4-20250514', name: 'Claude Sonnet 4' },
          { id: 'claude-opus-4-20250514', name: 'Claude Opus 4' },
          { id: 'claude-haiku-4-5-20251001', name: 'Claude Haiku 4.5' },
        ],
      },
      {
        provider: 'openai',
        label: 'OpenAI (ChatGPT)',
        models: [
          { id: 'gpt-4o-mini', name: 'GPT-4o Mini' },
          { id: 'gpt-4o', name: 'GPT-4o' },
          { id: 'gpt-4-turbo', name: 'GPT-4 Turbo' },
          { id: 'o4-mini', name: 'o4-mini' },
        ],
      },
      {
        provider: 'gemini',
        label: 'Google Gemini',
        models: [
          { id: 'gemini-2.0-flash', name: 'Gemini 2.0 Flash' },
          { id: 'gemini-2.5-flash', name: 'Gemini 2.5 Flash' },
          { id: 'gemini-2.5-pro', name: 'Gemini 2.5 Pro' },
        ],
      },
    ];
  }

  /** 모델 가격표 */
  getPricing(): Record<string, { input: number; output: number }> {
    return { ...MODEL_PRICING };
  }

  /* ───── 설정 관리 ───── */

  async getAllConfigs(): Promise<AiConfig[]> {
    return this.configRepo.find({ order: { id: 'ASC' } });
  }

  async updateConfig(
    provider: string,
    model?: string,
    apiKey?: string,
  ): Promise<AiConfig> {
    await this.configRepo
      .createQueryBuilder()
      .update(AiConfig)
      .set({ isActive: false })
      .where('isActive = :v', { v: true })
      .execute();

    let config = await this.configRepo.findOne({ where: { provider } });
    if (!config) {
      config = this.configRepo.create({
        provider,
        model: model ?? DEFAULT_MODELS[provider] ?? '',
        apiKey: apiKey ?? '',
        isActive: true,
      });
    } else {
      config.isActive = true;
      if (model) config.model = model;
      if (apiKey) config.apiKey = apiKey;
    }
    return this.configRepo.save(config);
  }

  /* ───── helpers ───── */

  private parseErrorMessage(raw: string): string | null {
    try {
      const j = JSON.parse(raw);
      return j.error?.message ?? j.error ?? null;
    } catch {
      return raw.slice(0, 200);
    }
  }
}
