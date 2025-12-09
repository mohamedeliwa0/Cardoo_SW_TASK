import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReadingsModule } from './readings/readings.module';
import { Reading } from './readings/reading.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: 'readings.db',
      entities: [Reading],
      synchronize: true,
    }),
    ReadingsModule,
  ],
})
export class AppModule {}

