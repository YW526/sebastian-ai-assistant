import { Controller, Post, Body, Get } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth/jwt-auth.guard';
import { ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Users')
@Controller('users')
export class UsersController {
    constructor(private readonly usersService: UsersService) {}

    @Post('signup')
    @ApiOperation({ summary: '회원가입' })
    async signup(@Body() dto: CreateUserDto) {
        return this.usersService.create(dto.email, dto.password);
    }

    @Get()
    async findAll() {
        return this.usersService.findAll();
    }
    @Get('me')
    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    getProfile(@Req() req) {
        return req.user;
    }
}