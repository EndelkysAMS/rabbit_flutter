import type { LineSubscription } from '../types';
import {
  planLabel,
  statusLabel,
  subscriptionStatusTone,
} from '../utils/subscriptionDisplay';

interface SubscriptionStatusChipProps {
  status: LineSubscription['status'];
}

export function SubscriptionStatusChip({ status }: SubscriptionStatusChipProps) {
  return (
    <span className={`chip chip--${subscriptionStatusTone(status)}`}>
      {statusLabel(status)}
    </span>
  );
}

interface PlanChipProps {
  plan: LineSubscription['plan'];
}

export function PlanChip({ plan }: PlanChipProps) {
  return <span className="chip">{planLabel(plan)}</span>;
}
