import { Repository } from 'typeorm';
import { Reading } from './reading.entity';
export declare class ReadingsService {
    private readonly readingsRepository;
    constructor(readingsRepository: Repository<Reading>);
    create(readingData: Partial<Reading>): Promise<Reading>;
    getLatest(): Promise<Reading>;
}
