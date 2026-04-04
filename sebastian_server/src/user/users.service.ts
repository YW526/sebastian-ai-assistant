import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
import { Persona } from '../chat/persona.entity';
import bcrypt from 'bcrypt';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

/** 가입 시 기본 활성 페르소나 (`persona.type`) */
const DEFAULT_PERSONA_TYPE = 'basic';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Persona)
    private personaRepository: Repository<Persona>,
  ) {}

  //회원가입
  async create(createUserDto: CreateUserDto): Promise<User> {
    const existingUser = await this.userRepository.findOne({ where: { email: createUserDto.email } });

    if (existingUser) {
      throw new ConflictException('이미 사용 중인 이메일입니다');
    }

    const hashedPassword = await bcrypt.hash(createUserDto.password, 10);

    const user = this.userRepository.create({
      ...createUserDto,
      password: hashedPassword,
    });

    const savedUser = await this.userRepository.save(user);

    const basicPersona = await this.personaRepository.findOne({
      where: { type: DEFAULT_PERSONA_TYPE },
    });
    if (basicPersona) {
      savedUser.activePersona = basicPersona;
      await this.userRepository.save(savedUser);
    }

    return savedUser;
  }

  //이메일로 사용자 찾기
  async findByEmail(email: string): Promise<User | null> {
    return await this.userRepository.findOne({ where: { email } });
  }

  //사용자 찾기
  async findAll(): Promise<User[]> {
    return await this.userRepository.find();
  }

  async findOne(id: number): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('사용자를 찾을 수 없습니다');
    }
    return user;
  }

  //비밀번호 변경
  async updatePassword(email: string, password: string): Promise<void> {
    const existingUser = await this.findByEmail(email);
    if (!existingUser) {
      throw new NotFoundException('사용자를 찾을 수 없습니다');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    Object.assign(existingUser, { password: hashedPassword });
    await this.userRepository.save(existingUser);
  }

  //사용자 삭제
  async remove(email: string): Promise<void> {
    const user = await this.findByEmail(email);
    if (!user) {
      throw new NotFoundException('사용자를 찾을 수 없습니다');
    }
    await this.userRepository.remove(user);
  }
}