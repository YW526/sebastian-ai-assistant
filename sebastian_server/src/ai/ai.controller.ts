import {
  Body,
  Controller,
  Delete,
  Get,
  Put,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { AiProviderService } from './ai-provider.service';
import { UpdateAiConfigDto } from './dto/update-ai-config.dto';

type JwtReq = { user: { userId: number; email: string } };

@ApiTags('AI')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('ai')
export class AiController {
  constructor(private readonly ai: AiProviderService) {}

  /* ───── 프로바이더 & 모델 목록 ───── */

  @Get('providers')
  @ApiOperation({ summary: '지원 프로바이더 · 모델 목록' })
  getProviders() {
    return this.ai.getProviders();
  }

  @Get('pricing')
  @ApiOperation({ summary: '모델별 토큰 가격표 (USD/1M tokens)' })
  getPricing() {
    return this.ai.getPricing();
  }

  /* ───── 설정 관리 ───── */

  @Get('config')
  @ApiOperation({ summary: '현재 AI 설정 목록 (API 키 마스킹)' })
  async getConfig() {
    const configs = await this.ai.getAllConfigs();
    return configs.map((c) => ({
      id: c.id,
      provider: c.provider,
      model: c.model,
      hasApiKey: !!c.apiKey,
      apiKeyHint: c.apiKey ? maskKey(c.apiKey) : '',
      isActive: c.isActive,
    }));
  }

  @Put('config')
  @ApiOperation({ summary: 'AI 프로바이더 활성화 & 설정 변경' })
  async updateConfig(@Body() dto: UpdateAiConfigDto) {
    const saved = await this.ai.updateConfig(
      dto.provider,
      dto.model,
      dto.apiKey,
    );
    return {
      id: saved.id,
      provider: saved.provider,
      model: saved.model,
      hasApiKey: !!saved.apiKey,
      isActive: saved.isActive,
    };
  }

  /* ───── 사용량 / 비용 ───── */

  @Get('usage/summary')
  @ApiOperation({ summary: 'AI 사용량 요약 (기간 필터)' })
  @ApiQuery({
    name: 'days',
    required: false,
    description: '최근 N일 (미입력 시 전체)',
    example: 30,
  })
  async getUsageSummary(
    @Req() req: JwtReq,
    @Query('days') daysRaw?: string,
  ) {
    const days = daysRaw ? Number(daysRaw) : undefined;
    return this.ai.getUsageSummary(req.user.userId, days);
  }

  @Delete('usage')
  @ApiOperation({ summary: '내 사용량 기록 초기화' })
  async clearUsage(@Req() req: JwtReq) {
    await this.ai.clearUsage(req.user.userId);
    return { cleared: true };
  }
}

function maskKey(key: string): string {
  if (key.length <= 8) return '••••••••';
  return key.slice(0, 4) + '••••' + key.slice(-4);
}
