import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Reading } from './reading.entity';

@Injectable()
export class ReadingsService {
  constructor(
    @InjectRepository(Reading)
    private readonly readingsRepository: Repository<Reading>,
  ) {}

  async create(readingData: Partial<Reading>) {
    const reading = this.readingsRepository.create(readingData);
    return this.readingsRepository.save(reading);
  }

  async getLatest() {
    return this.readingsRepository.findOne({
      where: {},                     // REQUIRED in TypeORM v0.3+
      order: { id: 'DESC' },         // get latest row
    });
  }
}

