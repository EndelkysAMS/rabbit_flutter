import { useMutation, useQuery } from '@tanstack/react-query';
import { Eye, EyeOff, UserPlus } from 'lucide-react';
import { useState } from 'react';
import toast from 'react-hot-toast';
import { createLineAdmin, getLineAdmins } from '../../api/super';
import { formatApiError } from '../../api/client';

interface SuperLineAdminsSectionProps {
  lineId: number;
  lineName: string;
}

export function SuperLineAdminsSection({
  lineId,
  lineName,
}: SuperLineAdminsSectionProps) {
  const [showPassword, setShowPassword] = useState(false);
  const [adminForm, setAdminForm] = useState({
    name: '',
    lastname: '',
    email: '',
    phone: '',
    password: '',
  });

  const {
    data: lineAdmins = [],
    isLoading: adminsLoading,
    refetch: refetchAdmins,
  } = useQuery({
    queryKey: ['super-line-admins', lineId],
    queryFn: () => getLineAdmins(lineId),
    enabled: Number.isFinite(lineId) && lineId > 0,
  });

  const createAdminMutation = useMutation({
    mutationFn: () => createLineAdmin(lineId, adminForm),
    onSuccess: (data) => {
      toast.success(`Admin creado: ${data.admin.email}`);
      setAdminForm({
        name: '',
        lastname: '',
        email: '',
        phone: '',
        password: '',
      });
      refetchAdmins();
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  return (
    <section id="line-admins" className="card card--section super-line-admins">
      <div className="super-line-admins__header">
        <div>
          <h3>
            <UserPlus size={20} style={{ verticalAlign: 'middle', marginRight: 8 }} />
            Administradores de línea
          </h3>
          <p className="text-muted">
            Crea usuarios con rol <strong>ADMIN_LINEA</strong> para{' '}
            <strong>{lineName}</strong>. Podrán entrar al panel web y gestionar
            conductores de su línea.
          </p>
        </div>
        <span className="chip">
          {lineAdmins.length} admin{lineAdmins.length === 1 ? '' : 'es'}
        </span>
      </div>

      {adminsLoading ? (
        <p className="text-muted">Cargando administradores…</p>
      ) : lineAdmins.length > 0 ? (
        <div className="table-wrap super-line-admins__table">
          <table className="data-table">
            <thead>
              <tr>
                <th>Nombre</th>
                <th>Email</th>
                <th>Teléfono</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              {lineAdmins.map((admin) => (
                <tr key={admin.id}>
                  <td>
                    {admin.name} {admin.lastname}
                  </td>
                  <td>{admin.email}</td>
                  <td>{admin.phone}</td>
                  <td>
                    {admin.is_active ? (
                      <span className="chip chip--success">Activo</span>
                    ) : (
                      <span className="chip chip--warning">Inactivo</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="alert alert--info">
          Esta línea aún no tiene administrador. Crea uno con el formulario de abajo.
        </div>
      )}

      <div className="super-line-admins__form-wrap">
        <h4>Nuevo administrador ADMIN_LINEA</h4>
        <form
          className="form-grid"
          onSubmit={(e) => {
            e.preventDefault();
            createAdminMutation.mutate();
          }}
        >
          <label className="field">
            <span>Nombre</span>
            <input
              required
              value={adminForm.name}
              onChange={(e) =>
                setAdminForm({ ...adminForm, name: e.target.value })
              }
              placeholder="Ej. Juan"
            />
          </label>
          <label className="field">
            <span>Apellido</span>
            <input
              required
              value={adminForm.lastname}
              onChange={(e) =>
                setAdminForm({ ...adminForm, lastname: e.target.value })
              }
              placeholder="Ej. Pérez"
            />
          </label>
          <label className="field">
            <span>Email (login)</span>
            <input
              type="email"
              required
              value={adminForm.email}
              onChange={(e) =>
                setAdminForm({ ...adminForm, email: e.target.value })
              }
              placeholder="admin@linea.com"
            />
          </label>
          <label className="field">
            <span>Teléfono</span>
            <input
              required
              value={adminForm.phone}
              onChange={(e) =>
                setAdminForm({ ...adminForm, phone: e.target.value })
              }
              placeholder="04141234567"
            />
          </label>
          <label className="field">
            <span>Contraseña inicial</span>
            <div className="password-field">
              <input
                type={showPassword ? 'text' : 'password'}
                required
                minLength={6}
                value={adminForm.password}
                onChange={(e) =>
                  setAdminForm({ ...adminForm, password: e.target.value })
                }
                placeholder="Mínimo 6 caracteres"
              />
              <button
                type="button"
                className="password-field__toggle"
                onClick={() => setShowPassword((v) => !v)}
                aria-label={
                  showPassword ? 'Ocultar contraseña' : 'Mostrar contraseña'
                }
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </label>
          <div className="field field--full super-form-actions">
            <button
              type="submit"
              className="btn btn--super btn--super-save"
              disabled={createAdminMutation.isPending}
            >
              {createAdminMutation.isPending
                ? 'Creando administrador…'
                : 'Crear administrador de línea'}
            </button>
          </div>
        </form>
      </div>
    </section>
  );
}
