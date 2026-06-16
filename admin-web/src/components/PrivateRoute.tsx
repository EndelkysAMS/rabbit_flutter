import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { isAdminLineaRole } from '../api/auth';

export function PrivateRoute() {
  const { isAuthenticated, user, logout } = useAuth();

  if (!isAuthenticated || !user) {
    return <Navigate to="/login" replace />;
  }

  if (!isAdminLineaRole(user.roles ?? [])) {
    logout();
    return <Navigate to="/login" replace state={{ denied: true }} />;
  }

  return <Outlet />;
}
