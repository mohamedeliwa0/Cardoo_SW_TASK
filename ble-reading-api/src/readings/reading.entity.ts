import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Reading {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  value: string;

  @Column({ type: 'bigint', nullable: true })
  timestamp: number;
}

