import { NavLink } from 'react-router-dom';
import { Building2, Menu, X } from 'lucide-react';

interface SuperSidebarProps {
  open: boolean;
  onClose: () => void;
}

const links = [{ to: '/super/lines', label: 'Líneas', icon: Building2 }];

export function SuperSidebar({ open, onClose }: SuperSidebarProps) {
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
      <aside className={`sidebar sidebar--super ${open ? 'sidebar--open' : ''}`}>
        <div className="sidebar__brand">
          <div>
            <strong>Rabbit Super</strong>
            <span>Administración global</span>
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
            </NavLink>
          ))}
        </nav>
      </aside>
    </>
  );
}

export function SuperSidebarToggle({ onOpen }: { onOpen: () => void }) {
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
