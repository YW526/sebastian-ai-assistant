import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
} from 'typeorm';

@Entity('users')
export class User {
  
  @PrimaryGeneratedColumn()
  id: number;

  //중복불가
  @Column({ unique: true })
  email: string;

  //비밀번호 해시
  @Column()
  password: string;

  @Column({ length: 100 })
  nickname: string;

  @Column({ type: 'date' })
  birthDate: string;

  @Column({ default: 'male' })
  gender: string;

  //가입일시 -> 자동생성
  @CreateDateColumn({ type: 'datetime' })
  createdAt: Date;
}
