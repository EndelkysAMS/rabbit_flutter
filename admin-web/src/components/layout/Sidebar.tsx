import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  UserPlus,
  Map,
  Route,
  UserCircle,
  DollarSign,
  Settings,
  Menu,
  X,
  CreditCard,
} from 'lucide-react';

interface SidebarProps {
  lineName?: string;
  subscriptionStatus?: 'activa' | 'morosa' | 'suspendida';
  open: boolean;
  onClose: () => void;
}

const links = [
  { to: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/drivers', label: 'Conductores', icon: Users },
  { to: '/drivers/new', label: 'Nuevo conductor', icon: UserPlus },
  { to: '/map', label: 'Mapa en vivo', icon: Map },
  { to: '/trips', label: 'Viajes', icon: Route },
  { to: '/clients', label: 'Clientes', icon: UserCircle },
  { to: '/fares', label: 'Tarifas', icon: DollarSign },
  { to: '/plan', label: 'Mi plan', icon: CreditCard },
  { to: '/profile', label: 'Mi perfil', icon: Settings },
];

export function Sidebar({
  lineName,
  subscriptionStatus,
  open,
  onClose,
}: SidebarProps) {
  return (
    <>
      {open && (
        <button
          type="button"
          className="sidebar-backdrop"
          aria-label="Cerrar menú"
          onClick={onClose}
        />
      )}
      <aside className={`sidebar ${open ? 'sidebar--open' : ''}`}>
        <div className="sidebar__brand">
          <div>
            <strong>Rabbit Admin</strong>
            <span>{lineName ?? 'Panel de línea'}</span>
          </div>
          <button
            type="button"
            className="sidebar__close"
            onClick={onClose}
            aria-label="Cerrar"
          >
            <X size={20} />
          </button>
        </div>
        <nav className="sidebar__nav">
          {links.map(({ to, label, icon: Icon }) => (
            <NavLink
              key={to}
              to={to}
              className={({ isActive }) =>
                `sidebar__link ${isActive ? 'sidebar__link--active' : ''}`
              }
              onClick={onClose}
            >
              <Icon size={18} />
              {label}
              {to === '/plan' && subscriptionStatus && subscriptionStatus !== 'activa' && (
                <span className="sidebar__link-badge" aria-label="Suscripción requiere atención" />
              )}
            </NavLink>
          ))}
        </nav>
      </aside>
    </>
  );
}

export function SidebarToggle({
  onOpen,
}: {
  onOpen: () => void;
}) {
  return (
    <button
      type="button"
      className="header__menu-btn"
      onClick={onOpen}
      aria-label="Abrir menú"
    >
      <Menu size={22} />
    </button>
  );
}
