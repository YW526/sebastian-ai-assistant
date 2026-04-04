import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { User } from './user.entity';
import { Persona } from '../chat/persona.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, Persona])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService], // 🔥 중요 (auth에서 사용)
})
export class UsersModule {}