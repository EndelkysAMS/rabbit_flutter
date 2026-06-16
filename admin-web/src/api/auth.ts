import { apiClient } from './client';
import type { AuthResponse, Role } from '../types';

export async function login(
  email: string,
  password: string,
): Promise<AuthResponse> {
  const { data } = await apiClient.post<AuthResponse>('/auth/login', {
    email,
    password,
  });
  return data;
}

export function isRabbitSuperRole(roles: Role[]): boolean {
  return roles.some((role) => String(role.id).toUpperCase() === 'RABBIT_SUPER');
}

export function isAdminLineaRole(roles: Role[]): boolean {
  return roles.some(
    (role) => String(role.id).toUpperCase() === 'ADMIN_LINEA',
  );
}

export type AdminPortal = 'linea' | 'super';

export function resolveAvailablePortals(roles: Role[]): AdminPortal[] {
  const portals: AdminPortal[] = [];
  if (isAdminLineaRole(roles)) portals.push('linea');
  if (isRabbitSuperRole(roles)) portals.push('super');
  return portals;
}

export function portalHomePath(portal: AdminPortal): string {
  return portal === 'super' ? '/super/lines' : '/dashboard';
}
