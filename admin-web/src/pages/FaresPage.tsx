import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import toast from 'react-hot-toast';
import { getFares, updateFares } from '../api/admin';
import { formatApiError } from '../api/client';
import { PageHeader } from '../components/PageHeader';

export function FaresPage() {
  const qc = useQueryClient();
  const { data, isLoading, isError, error } = useQuery({
    queryKey: ['fares'],
    queryFn: getFares,
  });

  const [kmValue, setKmValue] = useState('');
  const [minValue, setMinValue] = useState('');

  useEffect(() => {
    if (data) {
      setKmValue(String(data.km_value ?? ''));
      setMinValue(String(data.min_value ?? ''));
    }
  }, [data]);

  const mutation = useMutation({
    mutationFn: () =>
      updateFares({
        km_value: kmValue ? Number(kmValue) : undefined,
        min_value: minValue ? Number(minValue) : undefined,
      }),
    onSuccess: () => {
      toast.success('Tarifas actualizadas');
      qc.invalidateQueries({ queryKey: ['fares'] });
    },
    onError: (e) => toast.error(formatApiError(e)),
  });

  if (isLoading) return <div className="loading-block">Cargando…</div>;
  if (isError) return <div className="alert alert--danger">{formatApiError(error)}</div>;

  return (
    <div>
      <PageHeader
        title="Tarifas"
        subtitle="Configuración de precios por km y minuto"
      />
      {data?.uses_global_fallback && (
        <div className="alert alert--warning">
          Esta línea usa tarifas globales del sistema (
          {data.source ?? 'fallback'}). Los cambios pueden estar limitados.
        </div>
      )}
      <form
        className="card form-card"
        onSubmit={(e) => {
          e.preventDefault();
          mutation.mutate();
        }}
      >
        <p className="text-muted">
          Tarifa mínima garantizada: ${data?.min_fare_usd?.toFixed(2) ?? '0.80'} USD
        </p>
        <div className="form-grid">
          <label className="field">
            <span>Valor por km (km_value)</span>
            <input
              type="number"
              step="0.01"
              min="0"
              required
              value={kmValue}
              onChange={(e) => setKmValue(e.target.value)}
            />
          </label>
          <label className="field">
            <span>Valor por minuto (min_value)</span>
            <input
              type="number"
              step="0.01"
              min="0"
              required
              value={minValue}
              onChange={(e) => setMinValue(e.target.value)}
            />
          </label>
        </div>
        <div className="form-actions">
          <button
            type="submit"
            className="btn btn--primary"
            disabled={mutation.isPending}
          >
            {mutation.isPending ? 'Guardando…' : 'Guardar tarifas'}
          </button>
        </div>
      </form>
    </div>
  );
}
