export interface LoginResponse {
token: string;
expiration: string;
}
export interface LoginModel {
username?: string;
password?: string;
}