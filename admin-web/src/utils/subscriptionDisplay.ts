import {
  PLAN_LABELS,
  STATUS_LABELS,
  type PlanId,
  type SubscriptionStatus,
} from '../config/subscription';

export function subscriptionStatusTone(
  status: SubscriptionStatus,
): 'success' | 'warning' | 'danger' {
  if (status === 'activa') return 'success';
  if (status === 'morosa') return 'warning';
  return 'danger';
}

export function formatSubscriptionDate(value?: string | null): string {
  if (!value) return '—';
  return new Date(value).toLocaleDateString('es-VE', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

export function formatSubscriptionDateTime(value?: string | null): string {
  if (!value) return '—';
  return new Date(value).toLocaleString('es-VE', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

export function planLabel(plan: PlanId): string {
  return PLAN_LABELS[plan] ?? plan;
}

export function statusLabel(status: SubscriptionStatus): string {
  return STATUS_LABELS[status] ?? status;
}

export function driversLimitLabel(
  active?: number,
  max?: number | null,
): string {
  const activeCount = active ?? 0;
  if (max == null) return `${activeCount} conductores`;
  return `${activeCount}/${max}`;
}
