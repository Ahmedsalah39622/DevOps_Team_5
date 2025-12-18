import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { LoginModel, LoginResponse } from '../Modules/login.models';
import { environment } from '../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = `${environment.apiUrl}/Auth/login`;

  constructor(private http: HttpClient) { }

  login(credentials: LoginModel): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(this.apiUrl, credentials);
  }

  saveSession(response: LoginResponse): void {
    localStorage.setItem('jwt_token', response.token);
    localStorage.setItem('token_expiration', response.expiration);
  }

  getToken(): string | null {
    return localStorage.getItem('jwt_token');
  }

  logout(): void {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('token_expiration');
  }

  isLoggedIn(): boolean {
    const token = this.getToken();
    const expiration = localStorage.getItem('token_expiration');

    if (!token || !expiration) {
      return false;
    }

    const expirationDate = new Date(expiration);
    const now = new Date();

    return now < expirationDate;
  }
}