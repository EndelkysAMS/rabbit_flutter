import { Link, NavLink, Outlet } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { useState } from 'react';
import {
  deactivateDriver,
  deleteDriver,
  getDrivers,
  reactivateDriver,
} from '../api/admin';
import { formatApiError } from '../api/client';
import type { Driver } from '../types';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { DataTable, type Column } from '../components/DataTable';
import { PageHeader } from '../components/PageHeader';
import { ActiveBadge } from '../components/StatusBadge';

function DriversTabs() {
  return (
    <div className="tabs">
      <NavLink
        to="/drivers"
        end
        className={({ isActive }) => `tabs__item ${isActive ? 'tabs__item--active' : ''}`}
      >
        Activos
      </NavLink>
      <NavLink
        to="/drivers/inactive"
        className={({ isActive }) => `tabs__item ${isActive ? 'tabs__item--active' : ''}`}
      >
        Inactivos
      </NavLink>
    </div>
  );
}

export function DriversLayout() {
  return (
    <div>
      <PageHeader
        title="Conductores"
        subtitle="Gestión de conductores de la línea"
        actions={
          <Link to="/drivers/new" className="btn btn--primary">
            + Nuevo conductor
          </Link>
        }
      />
      <DriversTabs />
      <Outlet />
    </div>
  );
}

export function ActiveDriversPage() {
  const qc = useQueryClient();
  const [confirm, setConfirm] = useState<Driver | null>(null);

  const { data = [], isLoading } = useQuery({
    queryKey: ['drivers', 'active'],
    queryFn: () => getDrivers(true),
  });

  const deactivateMut = useMutation({
    mutationFn: (id: number) => deactivateDriver(id),
    onSuccess: () => {
      toast.success('Conductor desactivado');
      qc.invalidateQueries({ queryKey: ['drivers'] });
      setConfirm(null);
    },
    onError: (e) => toast.error(formatApiError(e)),
  });

  const columns: Column<Driver>[] = [
    {
      key: 'name',
      header: 'Conductor',
      render: (d) => (
        <Link to={`/drivers/${d.id}`} className="link">
          {d.name} {d.lastname}
        </Link>
      ),
    },
    { key: 'email', header: 'Email', render: (d) => d.email },
    { key: 'phone', header: 'Teléfono', render: (d) => d.phone },
    {
      key: 'status',
      header: 'Estado',
      render: (d) => <ActiveBadge active={d.is_active} />,
    },
    {
      key: 'actions',
      header: 'Acciones',
      render: (d) => (
        <button
          type="button"
          className="btn btn--ghost btn--sm"
          onClick={() => setConfirm(d)}
        >
          Desactivar
        </button>
      ),
    },
  ];

  return (
    <>
      <DataTable
        columns={columns}
        data={data}
        keyExtractor={(d) => d.id}
        loading={isLoading}
        emptyMessage="No hay conductores activos"
      />
      <ConfirmDialog
        open={Boolean(confirm)}
        title="Desactivar conductor"
        message={
          confirm
            ? `¿Desactivar a ${confirm.name} ${confirm.lastname}? Podrás reactivarlo después.`
            : null
        }
        danger
        loading={deactivateMut.isPending}
        confirmLabel="Desactivar"
        onCancel={() => setConfirm(null)}
        onConfirm={() => confirm && deactivateMut.mutate(confirm.id)}
      />
    </>
  );
}

export function InactiveDriversPage() {
  const qc = useQueryClient();
  const [reactivateTarget, setReactivateTarget] = useState<Driver | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Driver | null>(null);

  const { data = [], isLoading } = useQuery({
    queryKey: ['drivers', 'inactive'],
    queryFn: () => getDrivers(false),
  });

  const reactivateMut = useMutation({
    mutationFn: (id: number) => reactivateDriver(id),
    onSuccess: () => {
      toast.success('Conductor reactivado');
      qc.invalidateQueries({ queryKey: ['drivers'] });
      setReactivateTarget(null);
    },
    onError: (e) => toast.error(formatApiError(e)),
  });

  const deleteMut = useMutation({
    mutationFn: (id: number) => deleteDriver(id),
    onSuccess: () => {
      toast.success('Conductor eliminado definitivamente');
      qc.invalidateQueries({ queryKey: ['drivers'] });
      setDeleteTarget(null);
    },
    onError: (e) => toast.error(formatApiError(e)),
  });

  const columns: Column<Driver>[] = [
    {
      key: 'name',
      header: 'Conductor',
      render: (d) => (
        <Link to={`/drivers/${d.id}`} className="link">
          {d.name} {d.lastname}
        </Link>
      ),
    },
    { key: 'email', header: 'Email', render: (d) => d.email },
    { key: 'phone', header: 'Teléfono', render: (d) => d.phone },
    {
      key: 'actions',
      header: 'Acciones',
      render: (d) => (
        <div className="btn-row">
          <button
            type="button"
            className="btn btn--secondary btn--sm"
            onClick={() => setReactivateTarget(d)}
          >
            Reactivar
          </button>
          <button
            type="button"
            className="btn btn--danger btn--sm"
            onClick={() => setDeleteTarget(d)}
          >
            Eliminar
          </button>
        </div>
      ),
    },
  ];

  return (
    <>
      <DataTable
        columns={columns}
        data={data}
        keyExtractor={(d) => d.id}
        loading={isLoading}
        emptyMessage="No hay conductores inactivos"
      />
      <ConfirmDialog
        open={Boolean(reactivateTarget)}
        title="Reactivar conductor"
        message={
          reactivateTarget
            ? `¿Reactivar a ${reactivateTarget.name} ${reactivateTarget.lastname}?`
            : null
        }
        loading={reactivateMut.isPending}
        onCancel={() => setReactivateTarget(null)}
        onConfirm={() =>
          reactivateTarget && reactivateMut.mutate(reactivateTarget.id)
        }
      />
      <ConfirmDialog
        open={Boolean(deleteTarget)}
        title="Eliminar definitivamente"
        danger
        message={
          deleteTarget ? (
            <>
              <p>
                Esta acción es <strong>permanente</strong> para{' '}
                {deleteTarget.name} {deleteTarget.lastname}.
              </p>
              <p>¿Estás seguro de continuar?</p>
            </>
          ) : null
        }
        loading={deleteMut.isPending}
        confirmLabel="Eliminar definitivamente"
        onCancel={() => setDeleteTarget(null)}
        onConfirm={() => deleteTarget && deleteMut.mutate(deleteTarget.id)}
      />
    </>
  );
}