import { useNavigate, useParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import toast from 'react-hot-toast';
import {
  getDriver,
  updateDriver,
  uploadDriverPhoto,
} from '../api/admin';
import { formatApiError } from '../api/client';
import { PageHeader } from '../components/PageHeader';
import { ActiveBadge } from '../components/StatusBadge';

export function DriverEditPage() {
  const { id } = useParams<{ id: string }>();
  const driverId = Number(id);
  const navigate = useNavigate();
  const qc = useQueryClient();
  const [photo, setPhoto] = useState<File | null>(null);
  const [form, setForm] = useState({
    name: '',
    lastname: '',
    email: '',
    phone: '',
    password: '',
  });

  const { data: driver, isLoading, isError, error } = useQuery({
    queryKey: ['driver', driverId],
    queryFn: () => getDriver(driverId),
    enabled: Number.isFinite(driverId),
  });

  useEffect(() => {
    if (driver) {
      setForm({
        name: driver.name,
        lastname: driver.lastname,
        email: driver.email,
        phone: driver.phone,
        password: '',
      });
    }
  }, [driver]);

  const mutation = useMutation({
    mutationFn: async () => {
      const payload = {
        name: form.name,
        lastname: form.lastname,
        email: form.email,
        phone: form.phone,
        ...(form.password ? { password: form.password } : {}),
      };
      let updated = await updateDriver(driverId, payload);
      if (photo) {
        updated = await uploadDriverPhoto(driverId, photo);
      }
      return updated;
    },
    onSuccess: () => {
      toast.success('Conductor actualizado');
      qc.invalidateQueries({ queryKey: ['drivers'] });
      qc.invalidateQueries({ queryKey: ['driver', driverId] });
      navigate('/drivers');
    },
    onError: (e) => toast.error(formatApiError(e)),
  });

  if (isLoading) return <div className="loading-block">Cargando…</div>;
  if (isError) return <div className="alert alert--danger">{formatApiError(error)}</div>;
  if (!driver) return null;

  return (
    <div>
      <PageHeader
        title={`${driver.name} ${driver.lastname}`}
        subtitle="Editar conductor"
        actions={<ActiveBadge active={driver.is_active} />}
      />
      {driver.deactivated_at && (
        <div className="alert alert--warning">
          Desactivado el {new Date(driver.deactivated_at).toLocaleString()}
          {driver.deactivated_by &&
            ` por ${driver.deactivated_by.name} ${driver.deactivated_by.lastname}`}
        </div>
      )}
      <form
        className="card form-card"
        onSubmit={(e) => {
          e.preventDefault();
          mutation.mutate();
        }}
      >
        <div className="form-grid">
          <label className="field">
            <span>Nombre</span>
            <input
              required
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
            />
          </label>
          <label className="field">
            <span>Apellido</span>
            <input
              required
              value={form.lastname}
              onChange={(e) => setForm({ ...form, lastname: e.target.value })}
            />
          </label>
          <label className="field">
            <span>Email</span>
            <input
              type="email"
              required
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
            />
          </label>
          <label className="field">
            <span>Teléfono</span>
            <input
              required
              value={form.phone}
              onChange={(e) => setForm({ ...form, phone: e.target.value })}
            />
          </label>
          <label className="field">
            <span>Nueva contraseña (opcional)</span>
            <input
              type="password"
              value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })}
            />
          </label>
          <label className="field">
            <span>Foto</span>
            <input
              type="file"
              accept="image/*"
              onChange={(e) => setPhoto(e.target.files?.[0] ?? null)}
            />
          </label>
        </div>
        {driver.created_by_admin_linea && (
          <p className="text-muted">
            Creado por {driver.created_by_admin_linea.name}{' '}
            {driver.created_by_admin_linea.lastname}
          </p>
        )}
        <div className="form-actions">
          <button
            type="button"
            className="btn btn--ghost"
            onClick={() => navigate('/drivers')}
          >
            Volver
          </button>
          <button
            type="submit"
            className="btn btn--primary"
            disabled={mutation.isPending}
          >
            {mutation.isPending ? 'Guardando…' : 'Guardar cambios'}
          </button>
        </div>
      </form>
    </div>
  );
}
