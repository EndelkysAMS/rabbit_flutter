import { apiClient } from './client';
import type {
  ClientSummary,
  CreateDriverPayload,
  DashboardData,
  Driver,
  DriverPosition,
  FaresConfig,
  LineInfo,
  PaginatedResponse,
  Trip,
  TripDetail,
  UpdateDriverPayload,
  UpdateFaresPayload,
  UpdateProfilePayload,
} from '../types';

export async function getDashboard(): Promise<DashboardData> {
  const { data } = await apiClient.get<DashboardData>('/admin-linea/dashboard');
  return data;
}

export async function getLine(): Promise<LineInfo> {
  const { data } = await apiClient.get<LineInfo>('/admin-linea/line');
  return data;
}

export async function getDrivers(isActive = true): Promise<Driver[]> {
  const params = isActive ? undefined : { is_active: false };
  const { data } = await apiClient.get<Driver[]>('/admin-linea/drivers', {
    params,
  });
  return Array.isArray(data) ? data : [];
}

export async function getDriver(id: number): Promise<Driver> {
  const { data } = await apiClient.get<Driver>(`/admin-linea/drivers/${id}`);
  return data;
}

export async function createDriver(
  payload: CreateDriverPayload,
): Promise<Driver> {
  const { data } = await apiClient.post<Driver>(
    '/admin-linea/drivers',
    payload,
  );
  return data;
}

export async function updateDriver(
  id: number,
  payload: UpdateDriverPayload,
): Promise<Driver> {
  const { data } = await apiClient.patch<Driver>(
    `/admin-linea/drivers/${id}`,
    payload,
  );
  return data;
}

export async function deactivateDriver(id: number): Promise<void> {
  await apiClient.patch(`/admin-linea/drivers/${id}/deactivate`, {});
}

export async function reactivateDriver(id: number): Promise<void> {
  await apiClient.patch(`/admin-linea/drivers/${id}/reactivate`, {});
}

export async function deleteDriver(id: number): Promise<void> {
  await apiClient.delete(`/admin-linea/drivers/${id}`);
}

export async function uploadDriverPhoto(
  id: number,
  file: File,
): Promise<Driver> {
  const form = new FormData();
  form.append('file', file);
  const { data } = await apiClient.put<Driver>(
    `/admin-linea/drivers/${id}/upload`,
    form,
    { headers: { 'Content-Type': 'multipart/form-data' } },
  );
  return data;
}

export async function getDriverPositions(): Promise<DriverPosition[]> {
  const { data } = await apiClient.get<DriverPosition[]>(
    '/admin-linea/drivers/positions',
  );
  return Array.isArray(data) ? data : [];
}

export async function getTrips(params: {
  status?: string;
  from?: string;
  to?: string;
  search?: string;
  limit?: number;
  offset?: number;
}): Promise<PaginatedResponse<Trip>> {
  const { data } = await apiClient.get<PaginatedResponse<Trip>>(
    '/admin-linea/trips',
    { params },
  );
  return data;
}

export async function getTrip(id: number): Promise<TripDetail> {
  const { data } = await apiClient.get<TripDetail>(`/admin-linea/trips/${id}`);
  return data;
}

export async function exportTripsCsv(params: {
  status?: string;
  from?: string;
  to?: string;
  search?: string;
}): Promise<Blob> {
  const { data } = await apiClient.get<Blob>('/admin-linea/trips/export', {
    params,
    responseType: 'blob',
  });
  return data;
}

export async function getClients(params: {
  limit?: number;
  offset?: number;
  from?: string;
  to?: string;
  search?: string;
}): Promise<PaginatedResponse<ClientSummary>> {
  const { data } = await apiClient.get<PaginatedResponse<ClientSummary>>(
    '/admin-linea/clients',
    { params },
  );
  return data;
}

export async function exportClientsCsv(params: {
  from?: string;
  to?: string;
  search?: string;
}): Promise<Blob> {
  const { data } = await apiClient.get<Blob>('/admin-linea/clients/export', {
    params,
    responseType: 'blob',
  });
  return data;
}

export async function getFares(): Promise<FaresConfig> {
  const { data } = await apiClient.get<FaresConfig>('/admin-linea/fares');
  return data;
}

export async function updateFares(
  payload: UpdateFaresPayload,
): Promise<FaresConfig> {
  const { data } = await apiClient.patch<FaresConfig>(
    '/admin-linea/fares',
    payload,
  );
  return data;
}

export async function updateProfile(
  payload: UpdateProfilePayload,
): Promise<void> {
  await apiClient.patch('/admin-linea/profile', payload);
}
