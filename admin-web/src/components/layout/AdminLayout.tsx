import { Outlet } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { LogOut } from 'lucide-react';
import { useState } from 'react';
import { getDashboard } from '../../api/admin';
import { useAuth } from '../../hooks/useAuth';
import { Sidebar, SidebarToggle } from './Sidebar';

export function AdminLayout() {
  const { logout } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const { data: dashboard } = useQuery({
    queryKey: ['dashboard'],
    queryFn: getDashboard,
    staleTime: 60_000,
  });

  const lineName = dashboard?.line?.name;

  return (
    <div className="admin-shell">
      <Sidebar
        lineName={lineName}
        subscriptionStatus={dashboard?.line?.subscription?.status}
        open={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
      />
      <div className="admin-main">
        <header className="admin-header">
          <SidebarToggle onOpen={() => setSidebarOpen(true)} />
          <div className="admin-header__info">
            <h2>Línea</h2>
            <p>{lineName ?? '—'}</p>
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
