const TRIP_STATUS_MAP: Record<
  string,
  { label: string; className: string }
> = {
  CREATED: { label: 'Creado', className: 'badge--muted' },
  ACCEPTED: { label: 'Aceptado', className: 'badge--info' },
  ON_THE_WAY: { label: 'En camino', className: 'badge--info' },
  ARRIVED: { label: 'Llegó', className: 'badge--warning' },
  TRAVELLING: { label: 'En viaje', className: 'badge--warning' },
  FINISHED: { label: 'Finalizado', className: 'badge--success' },
  CANCELLED: { label: 'Cancelado', className: 'badge--danger' },
};

interface StatusBadgeProps {
  status: string;
}

export function StatusBadge({ status }: StatusBadgeProps) {
  const key = status.toUpperCase();
  const meta = TRIP_STATUS_MAP[key] ?? {
    label: status,
    className: 'badge--muted',
  };
  return (
    <span className={`badge ${meta.className}`}>{meta.label}</span>
  );
}

export function ActiveBadge({ active }: { active: boolean }) {
  return (
    <span className={`badge ${active ? 'badge--success' : 'badge--danger'}`}>
      {active ? 'Activo' : 'Inactivo'}
    </span>
  );
}
