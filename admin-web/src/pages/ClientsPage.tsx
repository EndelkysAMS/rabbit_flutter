import { useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import toast from 'react-hot-toast';
import { exportClientsCsv, getClients } from '../api/admin';
import { formatApiError } from '../api/client';
import type { ClientSummary } from '../types';
import { DataTable, type Column } from '../components/DataTable';
import { PageHeader } from '../components/PageHeader';

export function ClientsPage() {
  const [search, setSearch] = useState('');
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [offset, setOffset] = useState(0);
  const limit = 20;

  const { data, isLoading, isError, error } = useQuery({
    queryKey: ['clients', search, from, to, offset],
    queryFn: () =>
      getClients({
        limit,
        offset,
        search: search.trim() || undefined,
        from: from || undefined,
        to: to || undefined,
      }),
  });

  const handleExport = async () => {
    try {
      const blob = await exportClientsCsv({
        search: search.trim() || undefined,
        from: from || undefined,
        to: to || undefined,
      });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `clientes_${Date.now()}.csv`;
      a.click();
      URL.revokeObjectURL(url);
      toast.success('CSV descargado');
    } catch (e) {
      toast.error(formatApiError(e));
    }
  };

  const columns: Column<ClientSummary>[] = [
    {
      key: 'name',
      header: 'Cliente',
      render: (c) => `${c.name} ${c.lastname}`,
    },
    { key: 'email', header: 'Email', render: (c) => c.email ?? '—' },
    { key: 'phone', header: 'Teléfono', render: (c) => c.phone ?? '—' },
    { key: 'trips', header: 'Viajes', render: (c) => c.trip_count },
    {
      key: 'finished',
      header: 'Finalizados',
      render: (c) => c.finished_trip_count,
    },
    {
      key: 'last',
      header: 'Último viaje',
      render: (c) =>
        c.last_trip_at
          ? new Date(c.last_trip_at).toLocaleDateString()
          : '—',
    },
  ];

  return (
    <div>
      <PageHeader
        title="Clientes"
        subtitle="Clientes con viajes en tu línea"
        actions={
          <button
            type="button"
            className="btn btn--secondary"
            onClick={handleExport}
          >
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
              placeholder="Nombre, email o teléfono"
              onChange={(e) => {
                setSearch(e.target.value);
                setOffset(0);
              }}
            />
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
        keyExtractor={(c) => c.id}
        loading={isLoading}
        emptyMessage="No hay clientes con estos filtros"
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
