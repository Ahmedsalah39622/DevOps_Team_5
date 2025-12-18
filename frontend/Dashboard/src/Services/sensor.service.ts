import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment';

export interface SensorData {
  id: number;
  type: string;
  value: string;
  timestamp: string;
  sensor_id: string;
  parsedValue?: any;
}

export interface DashboardInsights {
  insights: {
    airQuality: { status: string; average: number };
    traffic: { status: string; average: number };
    systemHealth: { activeSensors: number; totalReadingsLastHour: number };
  };
  latestWeather: SensorData;
  lastUpdated: string;
}

@Injectable({
  providedIn: 'root'
})
export class SensorService {
  private apiUrl = `${environment.apiUrl}/sensors`;

  constructor(private http: HttpClient) { }

  getStats(): Observable<DashboardInsights> {
    return this.http.get<DashboardInsights>(`${this.apiUrl}/dashboard-stats`);
  }

  getHistory(type?: string, sensorId?: string, from?: string, to?: string): Observable<SensorData[]> {
    let params = new HttpParams();
    if (type && type !== 'All') params = params.set('type', type);
    if (sensorId) params = params.set('sensorId', sensorId);
    if (from) params = params.set('from', from);
    if (to) params = params.set('to', to);

    return this.http.get<SensorData[]>(`${this.apiUrl}/history`, { params });
  }
}