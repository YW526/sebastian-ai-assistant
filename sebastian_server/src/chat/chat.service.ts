import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ChatMessages } from './chat_messages.entity';
import { Persona } from './persona.entity';
import { User } from '../user/user.entity';
import { SendChatMessageDto } from './dto/send-chat-message.dto';
import { UpdatePersonaProfileDto } from './dto/update-persona-profile.dto';
import { ChatMessageResponseDto } from './dto/chat-message-response.dto';
import { PersonaListItemDto } from './dto/persona-list-item.dto';
import { PersonaProfileResponseDto } from './dto/persona-profile-response.dto';
import { SendChatMessageResponseDto } from './dto/send-chat-message-response.dto';
import { OllamaService, OllamaChatMessage } from './ollama.service';

/** DB `persona.type` — 활성 페르소나가 없을 때 시스템 프롬프트 소스 */
const DEFAULT_PERSONA_TYPE = 'basic';

const DEFAULT_SYSTEM_PROMPT =
  '당신은 친절한 AI 비서입니다. 한국어로 간결하게 답합니다.';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(ChatMessages)
    private readonly chatMessagesRepo: Repository<ChatMessages>,
    @InjectRepository(Persona)
    private readonly personaRepo: Repository<Persona>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly ollama: OllamaService,
    private readonly config: ConfigService,
  ) {}

  private toMessageDto(row: ChatMessages): ChatMessageResponseDto {
    return {
      id: row.id,
      userId: row.userId,
      senderRole: row.senderRole,
      message: row.message,
      createdAt: row.createdAt,
    };
  }

  /** 활성 페르소나 → 없으면 `type=basic` 페르소나 → 없으면 고정 문구 */
  private async resolveSystemPrompt(user: User | null): Promise<string> {
    const fromActive = user?.activePersona?.system_prompt?.trim();
    if (fromActive) {
      return fromActive;
    }
    const basic = await this.personaRepo.findOne({
      where: { type: DEFAULT_PERSONA_TYPE },
    });
    const fromBasic = basic?.system_prompt?.trim();
    return fromBasic || DEFAULT_SYSTEM_PROMPT;
  }

  private toPersonaListItem(p: Persona): PersonaListItemDto {
    return {
      id: p.id,
      type: p.type,
      name: p.name,
      description: p.description,
      image: p.image,
    };
  }

  async getMessages(userId: number): Promise<ChatMessageResponseDto[]> {
    const rows = await this.chatMessagesRepo.find({
      where: { userId },
      order: { createdAt: 'ASC' },
    });
    return rows.map((r) => this.toMessageDto(r));
  }

  async sendMessage(
    userId: number,
    dto: SendChatMessageDto,
  ): Promise<SendChatMessageResponseDto> {
    const userRef = { id: userId } as User;

    const userRow = this.chatMessagesRepo.create({
      userId,
      user: userRef,
      senderRole: 'user',
      message: dto.message.trim(),
    });
    const userMessage = await this.chatMessagesRepo.save(userRow);

    const userWithPersona = await this.userRepo.findOne({
      where: { id: userId },
      relations: ['activePersona'],
    });
    const systemPrompt = await this.resolveSystemPrompt(userWithPersona);

    const maxHistory = Number(
      this.config.get<string>('OLLAMA_MAX_HISTORY_MESSAGES') ?? '40',
    );
    const historyCap = Number.isFinite(maxHistory) && maxHistory > 0
      ? maxHistory
      : 40;

    const allRows = await this.chatMessagesRepo.find({
      where: { userId },
      order: { createdAt: 'ASC' },
    });
    const contextRows = allRows
      .filter(
        (r) => r.senderRole === 'user' || r.senderRole === 'assistant',
      )
      .slice(-historyCap);

    const ollamaMessages: OllamaChatMessage[] = [
      { role: 'system', content: systemPrompt },
      ...contextRows.map((r) => ({
        role: r.senderRole as 'user' | 'assistant',
        content: r.message,
      })),
    ];

    let assistantText: string;
    try {
      assistantText = await this.ollama.chat(ollamaMessages);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      assistantText = `[Ollama 오류] ${msg}`;
    }

    const assistantRow = this.chatMessagesRepo.create({
      userId,
      user: userRef,
      senderRole: 'assistant',
      message: assistantText,
    });
    const assistantMessage = await this.chatMessagesRepo.save(assistantRow);

    return {
      userMessage: this.toMessageDto(userMessage),
      assistantMessage: this.toMessageDto(assistantMessage),
    };
  }

  async listPersonas(): Promise<PersonaListItemDto[]> {
    const list = await this.personaRepo.find({ order: { id: 'ASC' } });
    return list.map((p) => this.toPersonaListItem(p));
  }

  async getPersonaProfile(userId: number): Promise<PersonaProfileResponseDto> {
    const user = await this.userRepo.findOne({
      where: { id: userId },
      relations: ['activePersona'],
    });
    if (!user) {
      throw new NotFoundException('사용자를 찾을 수 없습니다');
    }
    return this.buildPersonaProfileResponse(user);
  }

  async updatePersonaProfile(
    userId: number,
    dto: UpdatePersonaProfileDto,
  ): Promise<PersonaProfileResponseDto> {
    const user = await this.userRepo.findOne({
      where: { id: userId },
      relations: ['activePersona'],
    });
    if (!user) {
      throw new NotFoundException('사용자를 찾을 수 없습니다');
    }

    if (dto.activePersonaId !== undefined) {
      if (dto.activePersonaId === null) {
        user.activePersona = null;
      } else {
        const persona = await this.personaRepo.findOne({
          where: { id: dto.activePersonaId },
        });
        if (!persona) {
          throw new BadRequestException('존재하지 않는 페르소나입니다');
        }
        user.activePersona = persona;
      }
    }

    if (dto.personaNickname !== undefined) {
      const v = dto.personaNickname;
      user.personaNickname =
        v === null || (typeof v === 'string' && v.trim() === '')
          ? null
          : v.trim();
    }

    await this.userRepo.save(user);

    const reloaded = await this.userRepo.findOne({
      where: { id: userId },
      relations: ['activePersona'],
    });
    if (!reloaded) {
      throw new NotFoundException('사용자를 찾을 수 없습니다');
    }
    return this.buildPersonaProfileResponse(reloaded);
  }

  private buildPersonaProfileResponse(user: User): PersonaProfileResponseDto {
    const ap = user.activePersona;
    return {
      activePersonaId: ap?.id ?? null,
      personaNickname: user.personaNickname,
      activePersona: ap ? this.toPersonaListItem(ap) : null,
    };
  }
}
