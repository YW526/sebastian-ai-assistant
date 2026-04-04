import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ChatMessages } from './chat_messages.entity';
import { Persona } from './persona.entity';
import { User } from '../user/user.entity';
import { ChatService } from './chat.service';
import { ChatController } from './chat.controller';
import { PersonaSeedService } from './persona-seed.service';
import { OllamaService } from './ollama.service';

@Module({
  imports: [TypeOrmModule.forFeature([ChatMessages, Persona, User])],
  controllers: [ChatController],
  providers: [ChatService, PersonaSeedService, OllamaService],
  exports: [ChatService],
})
export class ChatModule {}
