import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SensorService, SensorData, DashboardInsights } from '../../Services/sensor.service';
import { AuthService } from '../../Services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  stats: DashboardInsights | null = null;
  weatherData: any = null;
  sensorHistory: SensorData[] = [];
  
  filterType: string = 'All';
  filterSensorId: string = '';
  
  // Time filters (optional now, since backend limits to 1000)
  customStart: string = '';
  customEnd: string = '';

  isLoading: boolean = false;

  constructor(
    private sensorService: SensorService,
    private authService: AuthService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loadStats();
    this.loadHistory();
  }

  loadStats(): void {
    this.sensorService.getStats().subscribe({
      next: (data) => {
        this.stats = data;
        if (data.latestWeather && data.latestWeather.value) {
          try {
            this.weatherData = JSON.parse(data.latestWeather.value);
          } catch {
            this.weatherData = null;
          }
        }
      },
      error: (e) => console.error(e)
    });
  }

  loadHistory(): void {
    this.isLoading = true;
    
    // Prepare date params if user selected them
    let fromIso = '';
    let toIso = '';

    if (this.customStart) fromIso = new Date(this.customStart).toISOString().slice(0, -1);
    if (this.customEnd) toIso = new Date(this.customEnd).toISOString().slice(0, -1);

    this.sensorService.getHistory(this.filterType, this.filterSensorId, fromIso, toIso).subscribe({
      next: (data) => {
        this.sensorHistory = data.map(item => {
          if (item.value && item.value.trim().startsWith('{')) {
            try { return { ...item, parsedValue: JSON.parse(item.value) }; }
            catch { return { ...item, parsedValue: item.value }; }
          }
          return { ...item, parsedValue: item.value };
        });
        this.isLoading = false;
      },
      error: () => this.isLoading = false
    });
  }

  applyFilters(): void {
    this.loadHistory();
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  // Styles
  getPollutionClass(status: string): string {
    if (status === 'Good') return 'card-good';
    if (status === 'Moderate') return 'card-warning';
    return 'card-danger';
  }

  getTrafficClass(status: string): string {
    if (status === 'Clear') return 'card-good';
    if (status === 'Moderate') return 'card-warning';
    return 'card-danger';
  }
}