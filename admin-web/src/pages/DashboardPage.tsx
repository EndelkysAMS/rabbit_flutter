import { useQuery } from '@tanstack/react-query';
import {
  Users,
  MapPin,
  Route,
  DollarSign,
  TrendingUp,
} from 'lucide-react';
import { getDashboard } from '../api/admin';
import { PageHeader } from '../components/PageHeader';
import { StatCard, StatCardSkeleton } from '../components/StatCard';
import { formatApiError } from '../api/client';

export function DashboardPage() {
  const { data, isLoading, isError, error } = useQuery({
    queryKey: ['dashboard'],
    queryFn: getDashboard,
  });

  if (isError) {
    return (
      <div className="alert alert--danger">{formatApiError(error)}</div>
    );
  }

  return (
    <div>
      <PageHeader
        title="Dashboard"
        subtitle={
          data?.line?.name
            ? `Resumen operativo — ${data.line.name}`
            : 'Resumen operativo de la línea'
        }
      />
      <div className="stat-grid">
        {isLoading ? (
          Array.from({ length: 6 }).map((_, i) => (
            <StatCardSkeleton key={i} />
          ))
        ) : (
          <>
            <StatCard
              label="Conductores activos"
              value={data?.drivers.active ?? 0}
              icon={Users}
              tone="success"
            />
            <StatCard
              label="Conductores inactivos"
              value={data?.drivers.inactive ?? 0}
              icon={Users}
              tone="warning"
            />
            <StatCard
              label="Con GPS"
              value={data?.drivers.with_live_position ?? 0}
              icon={MapPin}
              tone="info"
            />
            <StatCard
              label="Viajes hoy"
              value={data?.trips.today ?? 0}
              icon={Route}
            />
            <StatCard
              label="Ingresos totales (USD)"
              value={`$${(data?.revenue.total_finished_usd ?? 0).toFixed(2)}`}
              icon={DollarSign}
              tone="success"
            />
            <StatCard
              label="Ingresos hoy (USD)"
              value={`$${(data?.revenue.today_finished_usd ?? 0).toFixed(2)}`}
              icon={TrendingUp}
              tone="info"
            />
          </>
        )}
      </div>
      {data && (
        <div className="card card--section">
          <h3>Viajes por estado</h3>
          <div className="chip-row">
            <span className="chip">Total: {data.trips.total}</span>
            <span className="chip">Creados: {data.trips.created}</span>
            <span className="chip">En curso: {data.trips.in_progress}</span>
            <span className="chip">Finalizados: {data.trips.finished}</span>
            <span className="chip">Cancelados: {data.trips.cancelled}</span>
          </div>
        </div>
      )}
    </div>
  );
}
