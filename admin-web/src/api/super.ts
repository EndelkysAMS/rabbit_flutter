import axios from 'axios';
import { apiClient } from './client';
import type { CreateLineAdminBody, CreateLineBody, LineAdminUser, LineSubscription, SuperLine } from '../types';
import type { PlanId, SubscriptionStatus } from '../config/subscription';

export interface PatchSubscriptionBody {
  plan?: PlanId;
  status?: SubscriptionStatus;
  notes?: string | null;
  next_billing_at?: string | null;
  last_payment_at?: string | null;
}

export interface RecordPaymentBody {
  plan?: PlanId;
  notes?: string | null;
  last_payment_at?: string | null;
}

export interface SubscriptionMutationResponse {
  success?: boolean;
  line_id?: number;
  subscription: LineSubscription;
}

export async function getSuperLines(): Promise<SuperLine[]> {
  const { data } = await apiClient.get<SuperLine[]>('/admin/super/lines');
  return Array.isArray(data) ? data : [];
}

export async function createLine(
  body: CreateLineBody,
): Promise<{ success: boolean; message: string; line: SuperLine; admin?: LineAdminUser }> {
  const { data } = await apiClient.post<{
    success: boolean;
    message: string;
    line: SuperLine;
    admin?: LineAdminUser;
  }>('/admin/super/lines', body);
  return data;
}

export async function patchLineSubscription(
  id: number,
  body: PatchSubscriptionBody,
): Promise<SubscriptionMutationResponse> {
  const { data } = await apiClient.patch<SubscriptionMutationResponse>(
    `/admin/super/lines/${id}/subscription`,
    body,
  );
  return data;
}

export async function recordLinePayment(
  id: number,
  body: RecordPaymentBody,
): Promise<SubscriptionMutationResponse> {
  const { data } = await apiClient.post<SubscriptionMutationResponse>(
    `/admin/super/lines/${id}/subscription/record-payment`,
    body,
  );
  return data;
}

export async function activateLine(
  id: number,
): Promise<SubscriptionMutationResponse> {
  const { data } = await apiClient.post<SubscriptionMutationResponse>(
    `/admin/super/lines/${id}/subscription/activate`,
    {},
  );
  return data;
}

export async function suspendLine(
  id: number,
): Promise<SubscriptionMutationResponse> {
  const { data } = await apiClient.post<SubscriptionMutationResponse>(
    `/admin/super/lines/${id}/subscription/suspend`,
    {},
  );
  return data;
}

export async function getLineAdmins(lineId: number): Promise<LineAdminUser[]> {
  const { data } = await apiClient.get<LineAdminUser[]>(
    `/admin/super/lines/${lineId}/admins`,
  );
  return Array.isArray(data) ? data : [];
}

export async function createLineAdmin(
  lineId: number,
  body: CreateLineAdminBody,
): Promise<{ success: boolean; admin: LineAdminUser }> {
  const { data } = await apiClient.post<{ success: boolean; admin: LineAdminUser }>(
    `/admin/super/lines/${lineId}/admins`,
    body,
  );
  return data;
}

export async function getSuperMe(): Promise<{
  id: number;
  email: string;
  roles: string[];
  is_super_admin: boolean;
}> {
  const { data } = await apiClient.get('/admin/super/me');
  return data;
}

export async function deleteLine(id: number): Promise<{ success: boolean; message: string }> {
  const attempts: Array<{ url: string; body: Record<string, unknown> }> = [
    { url: '/admin/super/delete-line', body: { line_id: id } },
    { url: `/admin/super/lines/${id}/delete`, body: {} },
    { url: `/admin/super/lines/${id}`, body: {} },
  ];

  let lastError: unknown;
  for (const attempt of attempts) {
    try {
      const { data } = await apiClient.post<{ success: boolean; message: string }>(
        attempt.url,
        attempt.body,
      );
      return data;
    } catch (err) {
      lastError = err;
      if (!axios.isAxiosError(err)) throw err;
      const status = err.response?.status;
      if (status !== 404 && status !== 405) throw err;
    }
  }

  throw lastError;
}
