import axios, { AxiosError } from 'axios';
import type { ApiErrorBody } from '../types';

const baseURL =
  import.meta.env.VITE_API_BASE_URL ?? 'http://192.168.10.3:3000';
export const apiClient = axios.create({
  baseURL,
  headers: { 'Content-Type': 'application/json' },
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('rabbit_admin_token');
  if (token) {
    const trimmed = token.trim();
    config.headers.Authorization = trimmed.toLowerCase().startsWith('bearer ')
      ? trimmed
      : `Bearer ${trimmed}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiErrorBody>) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('rabbit_admin_token');
      localStorage.removeItem('rabbit_admin_user');
      if (window.location.pathname !== '/login') {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  },
);

export function formatApiError(error: unknown): string {
  if (axios.isAxiosError(error)) {
    const data = error.response?.data as ApiErrorBody & {
      email?: string;
      roles?: string[];
    };
    if (data?.message) {
      const base = Array.isArray(data.message)
        ? data.message.join(', ')
        : String(data.message);
      if (data.email) {
        return `${base} (cuenta: ${data.email}, roles: ${(data.roles ?? []).join(', ') || 'ninguno'})`;
      }
      return base;
    }
    if (data?.detail) return String(data.detail);
    if (error.response?.status === 403) {
      return 'Acceso denegado (403). Cierra sesión e inicia con endelkysmatos@gmail.com como Super Admin Rabbit.';
    }
    if (error.response?.status === 404) {
      return 'Endpoint no encontrado (404). Reinicia el servidor Django para cargar los cambios.';
    }
    if (error.message) return error.message;
  }
  if (error instanceof Error) return error.message;
  return 'Error inesperado';
}
