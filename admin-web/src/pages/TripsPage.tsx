import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import toast from 'react-hot-toast';
import { exportTripsCsv, getTrips } from '../api/admin';
import { formatApiError } from '../api/client';
import type { Trip } from '../types';
import { DataTable, type Column } from '../components/DataTable';
import { PageHeader } from '../components/PageHeader';
import { StatusBadge } from '../components/StatusBadge';

const STATUS_OPTIONS = [
  '',
  'CREATED',
  'ACCEPTED',
  'ON_THE_WAY',
  'ARRIVED',
  'TRAVELLING',
  'FINISHED',
  'CANCELLED',
];

export function TripsPage() {
  const [status, setStatus] = useState('');
  const [search, setSearch] = useState('');
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [offset, setOffset] = useState(0);
  const limit = 20;

  const { data, isLoading, isError, error } = useQuery({
    queryKey: ['trips', status, search, from, to, offset],
    queryFn: () =>
      getTrips({
        status: status || undefined,
        search: search.trim() || undefined,
        from: from || undefined,
        to: to || undefined,
        limit,
        offset,
      }),
  });

  const handleExport = async () => {
    try {
      const blob = await exportTripsCsv({
        status: status || undefined,
        search: search.trim() || undefined,
        from: from || undefined,
        to: to || undefined,
      });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `viajes_${Date.now()}.csv`;
      a.click();
      URL.revokeObjectURL(url);
      toast.success('CSV descargado');
    } catch (e) {
      toast.error(formatApiError(e));
    }
  };

  const columns: Column<Trip>[] = [
    {
      key: 'id',
      header: '#',
      render: (t) => (
        <Link to={`/trips/${t.id}`} className="link">
          {t.id}
        </Link>
      ),
    },
    {
      key: 'status',
      header: 'Estado',
      render: (t) => <StatusBadge status={t.status} />,
    },
    {
      key: 'client',
      header: 'Cliente',
      render: (t) =>
        t.client ? `${t.client.name} ${t.client.lastname}` : '—',
    },
    {
      key: 'driver',
      header: 'Conductor',
      render: (t) =>
        t.driver ? `${t.driver.name} ${t.driver.lastname}` : '—',
    },
    {
      key: 'fare',
      header: 'Tarifa',
      render: (t) => t.fare_assigned ?? t.fare_offered ?? '—',
    },
    {
      key: 'revenue',
      header: 'Ingreso',
      render: (t) =>
        t.revenue != null ? `$${Number(t.revenue).toFixed(2)}` : '—',
    },
    {
      key: 'created',
      header: 'Creado',
      render: (t) =>
        t.created_at
          ? new Date(t.created_at).toLocaleString()
          : '—',
    },
  ];

  return (
    <div>
      <PageHeader
        title="Viajes"
        subtitle="Historial y seguimiento de solicitudes"
        actions={
          <button type="button" className="btn btn--secondary" onClick={handleExport}>
            Exportar CSV
          </button>
        }
      />
      <div className="card filters-card">
        <div className="filters-row">
          <label className="field field--inline field--grow">
            <span>Buscar</span>
            <input
              type="search"
              value={search}
              placeholder="Cliente, conductor o dirección"
              onChange={(e) => {
                setSearch(e.target.value);
                setOffset(0);
              }}
            />
          </label>
          <label className="field field--inline">
            <span>Estado</span>
            <select
              value={status}
              onChange={(e) => {
                setStatus(e.target.value);
                setOffset(0);
              }}
            >
              <option value="">Todos</option>
              {STATUS_OPTIONS.filter(Boolean).map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
          </label>
          <label className="field field--inline">
            <span>Desde</span>
            <input
              type="date"
              value={from}
              onChange={(e) => {
                setFrom(e.target.value);
                setOffset(0);
              }}
            />
          </label>
          <label className="field field--inline">
            <span>Hasta</span>
            <input
              type="date"
              value={to}
              onChange={(e) => {
                setTo(e.target.value);
                setOffset(0);
              }}
            />
          </label>
        </div>
      </div>
      {isError && (
        <div className="alert alert--danger">{formatApiError(error)}</div>
      )}
      <DataTable
        columns={columns}
        data={data?.results ?? []}
        keyExtractor={(t) => t.id}
        loading={isLoading}
        emptyMessage="No hay viajes con estos filtros"
      />
      {data && data.count > limit && (
        <div className="pagination">
          <button
            type="button"
            className="btn btn--ghost"
            disabled={offset === 0}
            onClick={() => setOffset(Math.max(0, offset - limit))}
          >
            Anterior
          </button>
          <span>
            {offset + 1}–{Math.min(offset + limit, data.count)} de {data.count}
          </span>
          <button
            type="button"
            className="btn btn--ghost"
            disabled={offset + limit >= data.count}
            onClick={() => setOffset(offset + limit)}
          >
            Siguiente
          </button>
        </div>
      )}
    </div>
  );
}
