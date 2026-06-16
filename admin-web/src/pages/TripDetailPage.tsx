import { Link, useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { getTrip } from '../api/admin';
import { formatApiError } from '../api/client';
import { PageHeader } from '../components/PageHeader';
import { StatusBadge } from '../components/StatusBadge';
import { DataTable, type Column } from '../components/DataTable';
import type { TripOffer } from '../types';

export function TripDetailPage() {
  const { id } = useParams<{ id: string }>();
  const tripId = Number(id);

  const { data, isLoading, isError, error } = useQuery({
    queryKey: ['trip', tripId],
    queryFn: () => getTrip(tripId),
    enabled: Number.isFinite(tripId),
  });

  if (isLoading) return <div className="loading-block">Cargando…</div>;
  if (isError) return <div className="alert alert--danger">{formatApiError(error)}</div>;
  if (!data) return null;

  const offerColumns: Column<TripOffer>[] = [
    { key: 'id', header: '#', render: (o) => o.id },
    {
      key: 'driver',
      header: 'Conductor',
      render: (o) =>
        o.driver ? `${o.driver.name} ${o.driver.lastname}` : '—',
    },
    { key: 'fare', header: 'Tarifa', render: (o) => o.fare_offered },
    {
      key: 'date',
      header: 'Fecha',
      render: (o) =>
        o.created_at ? new Date(o.created_at).toLocaleString() : '—',
    },
  ];

  return (
    <div>
      <PageHeader
        title={`Viaje #${data.id}`}
        subtitle={data.pickup_description ?? 'Detalle del viaje'}
        actions={<StatusBadge status={data.status} />}
      />
      <div className="detail-grid">
        <div className="card">
          <h3>Ruta</h3>
          <p>
            <strong>Recoger:</strong> {data.pickup_description ?? '—'}
          </p>
          <p>
            <strong>Destino:</strong> {data.destination_description ?? '—'}
          </p>
        </div>
        <div className="card">
          <h3>Participantes</h3>
          <p>
            <strong>Cliente:</strong>{' '}
            {data.client
              ? `${data.client.name} ${data.client.lastname}`
              : '—'}
          </p>
          <p>
            <strong>Conductor:</strong>{' '}
            {data.driver
              ? `${data.driver.name} ${data.driver.lastname}`
              : '—'}
          </p>
        </div>
        <div className="card">
          <h3>Tarifas</h3>
          <p>
            <strong>Ofrecida:</strong> {data.fare_offered ?? '—'}
          </p>
          <p>
            <strong>Asignada:</strong> {data.fare_assigned ?? '—'}
          </p>
          <p>
            <strong>Ingreso:</strong>{' '}
            {data.revenue != null
              ? `$${Number(data.revenue).toFixed(2)}`
              : '—'}
          </p>
        </div>
      </div>
      <div className="card card--section">
        <h3>Ofertas de conductores</h3>
        <DataTable
          columns={offerColumns}
          data={data.offers ?? []}
          keyExtractor={(o) => o.id}
          emptyMessage="Sin ofertas registradas"
        />
      </div>
      <Link to="/trips" className="btn btn--ghost">
        ← Volver al listado
      </Link>
    </div>
  );
}
