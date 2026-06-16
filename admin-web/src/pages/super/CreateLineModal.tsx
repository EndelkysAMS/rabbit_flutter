import { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';
import type { CreateLineBody } from '../../types';

interface CreateLineModalProps {
  open: boolean;
  loading: boolean;
  onClose: () => void;
  onSubmit: (body: CreateLineBody) => void;
}

const emptyAdmin = {
  name: '',
  lastname: '',
  email: '',
  phone: '',
  password: '',
};

export function CreateLineModal({
  open,
  loading,
  onClose,
  onSubmit,
}: CreateLineModalProps) {
  const [lineName, setLineName] = useState('');
  const [withAdmin, setWithAdmin] = useState(true);
  const [showPassword, setShowPassword] = useState(false);
  const [admin, setAdmin] = useState(emptyAdmin);

  if (!open) return null;

  function handleClose() {
    setLineName('');
    setWithAdmin(true);
    setAdmin(emptyAdmin);
    onClose();
  }

  return (
    <div className="dialog-overlay" role="presentation" onClick={handleClose}>
      <div
        className="dialog dialog--wide"
        role="dialog"
        aria-modal="true"
        onClick={(e) => e.stopPropagation()}
      >
        <h3>Nueva línea — Plan Piloto</h3>
        <p className="text-muted" style={{ marginTop: 0 }}>
          Se crea la línea con plan <strong>Piloto</strong> (3 meses, $0) y estado
          activa. Opcionalmente puedes crear el administrador de la línea en el mismo
          paso.
        </p>

        <div className="dialog__body">
          <label className="field field--full">
            <span>Nombre de la línea</span>
            <input
              required
              value={lineName}
              onChange={(e) => setLineName(e.target.value)}
              placeholder="Ej. Mototaxi El Centro"
            />
          </label>

          <label className="field field--full" style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <input
              type="checkbox"
              checked={withAdmin}
              onChange={(e) => setWithAdmin(e.target.checked)}
            />
            <span>Crear administrador de línea ahora</span>
          </label>

          {withAdmin && (
            <div className="form-grid" style={{ marginTop: 12 }}>
              <label className="field">
                <span>Nombre del admin</span>
                <input
                  required={withAdmin}
                  value={admin.name}
                  onChange={(e) => setAdmin({ ...admin, name: e.target.value })}
                />
              </label>
              <label className="field">
                <span>Apellido</span>
                <input
                  required={withAdmin}
                  value={admin.lastname}
                  onChange={(e) => setAdmin({ ...admin, lastname: e.target.value })}
                />
              </label>
              <label className="field">
                <span>Email (login)</span>
                <input
                  type="email"
                  required={withAdmin}
                  value={admin.email}
                  onChange={(e) => setAdmin({ ...admin, email: e.target.value })}
                />
              </label>
              <label className="field">
                <span>Teléfono</span>
                <input
                  required={withAdmin}
                  value={admin.phone}
                  onChange={(e) => setAdmin({ ...admin, phone: e.target.value })}
                />
              </label>
              <label className="field field--full">
                <span>Contraseña inicial</span>
                <div className="password-field">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    required={withAdmin}
                    minLength={6}
                    value={admin.password}
                    onChange={(e) =>
                      setAdmin({ ...admin, password: e.target.value })
                    }
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
            </div>
          )}
        </div>

        <div className="dialog__actions">
          <button type="button" className="btn btn--ghost" onClick={handleClose}>
            Cancelar
          </button>
          <button
            type="button"
            className="btn btn--super btn--super-save"
            disabled={loading || !lineName.trim()}
            onClick={() => {
              const body: CreateLineBody = { name: lineName.trim() };
              if (withAdmin) {
                body.admin = admin;
              }
              onSubmit(body);
            }}
          >
            {loading ? 'Creando…' : 'Crear línea piloto'}
          </button>
        </div>
      </div>
    </div>
  );
}
