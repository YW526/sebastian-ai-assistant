import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class SendChatMessageDto {
  @ApiProperty({ example: '안녕', description: '사용자가 보낸 메시지 본문' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(8000)
  message: string;
}
