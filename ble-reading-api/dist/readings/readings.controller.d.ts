import { ReadingsService } from './readings.service';
export declare class ReadingsController {
    private readonly readingsService;
    constructor(readingsService: ReadingsService);
    create(body: any): Promise<import("./reading.entity").Reading>;
    getLatest(): Promise<import("./reading.entity").Reading>;
}
