import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from 'react-hot-toast';
import { AuthProvider, useAuth } from './hooks/useAuth';
import { PrivateRoute } from './components/PrivateRoute';
import { SuperPrivateRoute } from './components/SuperPrivateRoute';
import { AdminLayout } from './components/layout/AdminLayout';
import { SuperLayout } from './components/layout/SuperLayout';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import {
  ActiveDriversPage,
  DriversLayout,
  InactiveDriversPage,
} from './pages/DriversPage';
import { DriverNewPage } from './pages/DriverNewPage';
import { DriverEditPage } from './pages/DriverEditPage';
import { MapPage } from './pages/MapPage';
import { TripsPage } from './pages/TripsPage';
import { TripDetailPage } from './pages/TripDetailPage';
import { ClientsPage } from './pages/ClientsPage';
import { FaresPage } from './pages/FaresPage';
import { ProfilePage } from './pages/ProfilePage';
import { SubscriptionPage } from './pages/SubscriptionPage';
import { SuperLinesPage } from './pages/super/SuperLinesPage';
import { SuperLineDetailPage } from './pages/super/SuperLineDetailPage';
import { isAdminLineaRole, isRabbitSuperRole } from './api/auth';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

function DefaultRedirect() {
  const { isAuthenticated, user } = useAuth();
  if (!isAuthenticated || !user) {
    return <Navigate to="/login" replace />;
  }
  if (isRabbitSuperRole(user.roles ?? [])) {
    return <Navigate to="/super/lines" replace />;
  }
  if (isAdminLineaRole(user.roles ?? [])) {
    return <Navigate to="/dashboard" replace />;
  }
  return <Navigate to="/login" replace state={{ denied: true }} />;
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <BrowserRouter>
          <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route element={<PrivateRoute />}>
              <Route element={<AdminLayout />}>
                <Route path="/" element={<Navigate to="/dashboard" replace />} />
                <Route path="/dashboard" element={<DashboardPage />} />
                <Route path="/drivers" element={<DriversLayout />}>
                  <Route index element={<ActiveDriversPage />} />
                  <Route path="inactive" element={<InactiveDriversPage />} />
                </Route>
                <Route path="/drivers/new" element={<DriverNewPage />} />
                <Route path="/drivers/:id" element={<DriverEditPage />} />
                <Route path="/map" element={<MapPage />} />
                <Route path="/trips" element={<TripsPage />} />
                <Route path="/trips/:id" element={<TripDetailPage />} />
                <Route path="/clients" element={<ClientsPage />} />
                <Route path="/fares" element={<FaresPage />} />
                <Route path="/plan" element={<SubscriptionPage />} />
                <Route path="/profile" element={<ProfilePage />} />
              </Route>
            </Route>
            <Route element={<SuperPrivateRoute />}>
              <Route element={<SuperLayout />}>
                <Route
                  path="/super"
                  element={<Navigate to="/super/lines" replace />}
                />
                <Route path="/super/lines" element={<SuperLinesPage />} />
                <Route
                  path="/super/lines/:id"
                  element={<SuperLineDetailPage />}
                />
              </Route>
            </Route>
            <Route path="*" element={<DefaultRedirect />} />
          </Routes>
        </BrowserRouter>
        <Toaster position="top-right" />
      </AuthProvider>
    </QueryClientProvider>
  );
}
