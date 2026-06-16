import { useMutation } from '@tanstack/react-query';
import { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';
import { useLocation, useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';import toast from 'react-hot-toast';
import {
  login,
  portalHomePath,
  resolveAvailablePortals,
  type AdminPortal,
} from '../api/auth';
import { formatApiError } from '../api/client';
import type { AuthResponse } from '../types';
import { useAuth } from '../hooks/useAuth';

const SUPER_ROLE_ICON = '/roles/rabbit_super_role.png';

function roleIcon(portal: AdminPortal, roles: AuthResponse['user']['roles']) {
  if (portal === 'super') return SUPER_ROLE_ICON;
  const adminRole = roles.find(
    (r) => String(r.id).toUpperCase() === 'ADMIN_LINEA',
  );
  return adminRole?.image || SUPER_ROLE_ICON;
}

function roleTitle(portal: AdminPortal): string {
  return portal === 'super' ? 'Super Admin Rabbit' : 'Admin de línea';
}

function roleDescription(portal: AdminPortal): string {
  return portal === 'super'
    ? 'Gestiona suscripciones y líneas B2B2C'
    : 'Panel de conductores, viajes y tarifas de tu línea';
}

export function LoginPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const queryClient = useQueryClient();
  const { loginSession } = useAuth();  const denied = (location.state as { denied?: boolean; message?: string })?.denied;
  const deniedMessage = (location.state as { denied?: boolean; message?: string })?.message;

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [pendingAuth, setPendingAuth] = useState<AuthResponse | null>(null);

  const mutation = useMutation({
    mutationFn: () => login(email.trim(), password),
    onSuccess: (data) => {
      const roles = data.user.roles ?? [];
      const portals = resolveAvailablePortals(roles);

      if (portals.length === 0) {
        toast.error('Acceso denegado: se requiere ADMIN_LINEA o RABBIT_SUPER');
        return;
      }

      if (portals.length === 1) {
        queryClient.clear();
        loginSession(data.token, data.user);
        toast.success('Bienvenido');
        navigate(portalHomePath(portals[0]), { replace: true });
        return;
      }

      setPendingAuth(data);
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  function enterPortal(portal: AdminPortal) {
    if (!pendingAuth) return;
    queryClient.clear();
    loginSession(pendingAuth.token, pendingAuth.user);
    toast.success('Bienvenido');
    navigate(portalHomePath(portal), { replace: true });
  }

  if (pendingAuth) {
    const roles = pendingAuth.user.roles ?? [];
    const portals = resolveAvailablePortals(roles);

    return (
      <div className="login-page">
        <div className="login-card login-card--wide">
          <div className="login-card__brand">
            <h1>Rabbit</h1>
            <p className="text-muted">Elige cómo quieres entrar</p>
          </div>
          <div className="role-picker">
            {portals.map((portal) => (
              <button
                key={portal}
                type="button"
                className="role-card"
                onClick={() => enterPortal(portal)}
              >
                <img
                  src={roleIcon(portal, roles)}
                  alt=""
                  className="role-card__icon"
                />
                <strong>{roleTitle(portal)}</strong>
                <span>{roleDescription(portal)}</span>
              </button>
            ))}
          </div>
          <button
            type="button"
            className="btn btn--ghost btn--block"
            onClick={() => setPendingAuth(null)}
          >
            Volver
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="login-page">
      <div className="login-card">
        <div className="login-card__brand">
          <h1>Rabbit</h1>
        </div>
        {denied && (
          <div className="alert alert--danger">
            {deniedMessage ??
              'Acceso denegado. Solo administradores de línea o super-admin Rabbit.'}
          </div>
        )}        <form
          onSubmit={(e) => {
            e.preventDefault();
            mutation.mutate();
          }}
        >
          <label className="field">
            <span>Email</span>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoComplete="username"
            />
          </label>
          <label className="field">
            <span>Contraseña</span>
            <div className="password-field">
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                autoComplete="current-password"
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
          <button
            type="submit"
            className="btn btn--primary btn--block"
            disabled={mutation.isPending}
          >
            {mutation.isPending ? 'Entrando…' : 'Iniciar sesión'}
          </button>
        </form>
      </div>
    </div>
  );
}
