import { Navigate, Outlet } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { getSuperMe } from '../api/super';
import { formatApiError } from '../api/client';
import { useAuth } from '../hooks/useAuth';
import { isRabbitSuperRole } from '../api/auth';

export function SuperPrivateRoute() {
  const { isAuthenticated, user, logout } = useAuth();

  const sessionCheck = useQuery({
    queryKey: ['super-me'],
    queryFn: getSuperMe,
    enabled: isAuthenticated && Boolean(user),
    retry: false,
  });

  if (!isAuthenticated || !user) {
    return <Navigate to="/login" replace />;
  }

  if (!isRabbitSuperRole(user.roles ?? [])) {
    logout();
    return <Navigate to="/login" replace state={{ denied: true }} />;
  }

  if (sessionCheck.isLoading) {
    return (
      <div className="alert alert--info" style={{ margin: 24 }}>
        Verificando sesión de super admin…
      </div>
    );
  }

  if (sessionCheck.isError) {
    logout();
    return (
      <Navigate
        to="/login"
        replace
        state={{
          denied: true,
          message: formatApiError(sessionCheck.error),
        }}
      />
    );
  }

  return <Outlet />;
}