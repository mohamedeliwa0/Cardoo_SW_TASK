import { Controller, Get, Post, Body } from '@nestjs/common';
import { ReadingsService } from './readings.service';

@Controller('readings')
export class ReadingsController {
  constructor(private readonly readingsService: ReadingsService) {}

  @Post()
  create(@Body() body: any) {
    return this.readingsService.create(body);
  }

  @Get('latest')
  getLatest() {
    return this.readingsService.getLatest();
  }
}

