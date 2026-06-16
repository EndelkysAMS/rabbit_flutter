import { useNavigate } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import toast from 'react-hot-toast';
import { createDriver, uploadDriverPhoto } from '../api/admin';
import { formatApiError } from '../api/client';
import { PageHeader } from '../components/PageHeader';

export function DriverNewPage() {
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

  const mutation = useMutation({
    mutationFn: async () => {
      const driver = await createDriver(form);
      if (photo) {
        await uploadDriverPhoto(driver.id, photo);
      }
      return driver;
    },
    onSuccess: () => {
      toast.success('Conductor creado');
      qc.invalidateQueries({ queryKey: ['drivers'] });
      navigate('/drivers');
    },
    onError: (e) => toast.error(formatApiError(e)),
  });

  return (
    <div>
      <PageHeader
        title="Nuevo conductor"
        subtitle="Registrar un conductor en la línea"
      />
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
            <span>Contraseña</span>
            <input
              type="password"
              required
              value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })}
            />
          </label>
          <label className="field">
            <span>Foto (opcional)</span>
            <input
              type="file"
              accept="image/*"
              onChange={(e) => setPhoto(e.target.files?.[0] ?? null)}
            />
          </label>
        </div>
        <div className="form-actions">
          <button
            type="button"
            className="btn btn--ghost"
            onClick={() => navigate('/drivers')}
          >
            Cancelar
          </button>
          <button
            type="submit"
            className="btn btn--primary"
            disabled={mutation.isPending}
          >
            {mutation.isPending ? 'Creando…' : 'Crear conductor'}
          </button>
        </div>
      </form>
    </div>
  );
}
