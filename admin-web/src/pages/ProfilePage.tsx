import { useMutation } from '@tanstack/react-query';
import { useState } from 'react';
import toast from 'react-hot-toast';
import { updateProfile } from '../api/admin';
import { formatApiError } from '../api/client';
import { useAuth } from '../hooks/useAuth';
import { PageHeader } from '../components/PageHeader';

export function ProfilePage() {
  const { user, loginSession } = useAuth();
  const [form, setForm] = useState({
    name: user?.name ?? '',
    phone: user?.phone ?? '',
    password: '',
    image: user?.image ?? '',
  });

  const mutation = useMutation({
    mutationFn: () =>
      updateProfile({
        name: form.name,
        lastname: user?.lastname ?? '',
        phone: form.phone,
        image: form.image || null,
        ...(form.password ? { password: form.password } : {}),
      }),
    onSuccess: () => {
      toast.success('Perfil actualizado', { id: 'profile-update' });
      const token = localStorage.getItem('rabbit_admin_token');
      if (token && user) {
        loginSession(token, {
          ...user,
          name: form.name,
          phone: form.phone,
          image: form.image || undefined,
        });
      }
    },
    onError: (e) => toast.error(formatApiError(e)),
  });

  return (
    <div>
      <PageHeader title="Mi perfil" subtitle={user?.email} />
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
            <span>Teléfono</span>
            <input
              required
              value={form.phone}
              onChange={(e) => setForm({ ...form, phone: e.target.value })}
            />
          </label>
          <label className="field">
            <span>URL imagen (opcional)</span>
            <input
              value={form.image}
              onChange={(e) => setForm({ ...form, image: e.target.value })}
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
        </div>
        <div className="form-actions">
          <button
            type="submit"
            className="btn btn--primary"
            disabled={mutation.isPending}
          >
            {mutation.isPending ? 'Guardando…' : 'Actualizar perfil'}
          </button>
        </div>
      </form>
    </div>
  );
}
