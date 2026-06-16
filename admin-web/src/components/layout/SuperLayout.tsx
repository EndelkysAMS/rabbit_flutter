import { Outlet } from 'react-router-dom';
import { LogOut } from 'lucide-react';
import { useState } from 'react';
import { useAuth } from '../../hooks/useAuth';
import { SuperSidebar, SuperSidebarToggle } from './SuperSidebar';

export function SuperLayout() {
  const { user, logout } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="admin-shell admin-shell--super">
      <SuperSidebar
        open={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
      />
      <div className="admin-main">
        <header className="admin-header admin-header--super">
          <SuperSidebarToggle onOpen={() => setSidebarOpen(true)} />
          <div className="admin-header__info">
            <h2>Rabbit Super Admin</h2>
            <p>
              {user?.name} {user?.lastname}
            </p>
          </div>
          <button type="button" className="btn btn--ghost" onClick={logout}>
            <LogOut size={18} />
            Salir
          </button>
        </header>
        <main className="admin-content">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
