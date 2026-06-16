import type { LucideIcon } from 'lucide-react';

interface StatCardProps {
  label: string;
  value: string | number;
  icon: LucideIcon;
  tone?: 'default' | 'success' | 'warning' | 'danger' | 'info';
}

export function StatCard({
  label,
  value,
  icon: Icon,
  tone = 'default',
}: StatCardProps) {
  return (
    <div className={`stat-card stat-card--${tone}`}>
      <div className="stat-card__icon">
        <Icon size={22} />
      </div>
      <div>
        <p className="stat-card__label">{label}</p>
        <p className="stat-card__value">{value}</p>
      </div>
    </div>
  );
}

export function StatCardSkeleton() {
  return (
    <div className="stat-card stat-card--skeleton">
      <div className="skeleton skeleton--circle" />
      <div className="skeleton-group">
        <div className="skeleton skeleton--line short" />
        <div className="skeleton skeleton--line" />
      </div>
    </div>
  );
}
