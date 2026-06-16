export interface Role {
  id: string;
  name: string;
  route: string;
  image?: string;
}

export interface User {
  id: number;
  name: string;
  lastname: string;
  email: string;
  phone: string;
  image?: string;
  roles: Role[];
}

export interface AuthResponse {
  token: string;
  user: User;
}

export interface AdminUser {
  id: number;
  name: string;
  lastname: string;
  email: string;
}

export interface LineSubscription {
  plan: 'piloto' | 'basico' | 'pro';
  status: 'activa' | 'morosa' | 'suspendida';
  started_at?: string | null;
  pilot_ends_at?: string | null;
  next_billing_at?: string | null;
  last_payment_at?: string | null;
  days_until_pilot_end?: number | null;
  max_drivers?: number | null;
  active_drivers_count?: number;
  notes?: string | null;
}

export interface LineInfo {
  id: number;
  name: string;
  km_value?: number;
  min_value?: number;
  subscription?: LineSubscription;
}

export interface SuperLine {
  id: number;
  name: string;
  created_at: string;
  updated_at: string;
  subscription: LineSubscription;
}

export interface LineAdminUser {
  id: number;
  name: string;
  lastname: string;
  email: string;
  phone: string;
  is_active: boolean;
  created_at: string;
}

export interface CreateLineAdminBody {
  name: string;
  lastname: string;
  email: string;
  phone: string;
  password: string;
}

export interface CreateLineBody {
  name: string;
  admin?: CreateLineAdminBody;
}

export interface Driver {
  id: number;
  name: string;
  lastname: string;
  email: string;
  phone: string;
  image?: string;
  is_active: boolean;
  line?: LineInfo;
  roles?: string[];
  deactivated_at?: string | null;
  deactivated_by?: AdminUser | null;
  created_by_admin_linea?: AdminUser | null;
}

export interface DriverPosition {
  id_driver: number;
  lat: number;
  lng: number;
  name: string;
  lastname: string;
  phone: string;
  image?: string;
  is_active: boolean;
}

export interface DashboardData {
  line: LineInfo;
  drivers: {
    active: number;
    inactive: number;
    with_live_position: number;
  };
  trips: {
    total: number;
    created: number;
    in_progress: number;
    finished: number;
    cancelled: number;
    today: number;
  };
  revenue: {
    total_finished_usd: number;
    today_finished_usd: number;
  };
}

export interface TripClient {
  id: number;
  name: string;
  lastname: string;
  email?: string;
  phone?: string;
}

export interface TripDriver {
  id: number;
  name: string;
  lastname: string;
  phone?: string;
}

export interface TripPosition {
  x: number;
  y: number;
}

export interface Trip {
  id: number;
  status: string;
  fare_offered?: number;
  fare_assigned?: number;
  revenue?: number;
  pickup_description?: string;
  destination_description?: string;
  pickup_position?: TripPosition;
  destination_position?: TripPosition;
  client?: TripClient;
  driver?: TripDriver;
  client_rating?: number;
  driver_rating?: number;
  created_at?: string;
  updated_at?: string;
}

export interface TripOffer {
  id: number;
  fare_offered: number;
  driver?: TripDriver;
  created_at?: string;
}

export interface TripDetail extends Trip {
  offers?: TripOffer[];
}

export interface PaginatedResponse<T> {
  count: number;
  limit: number;
  offset: number;
  results: T[];
}

export interface ClientSummary {
  id: number;
  name: string;
  lastname: string;
  email?: string;
  phone?: string;
  trip_count: number;
  finished_trip_count: number;
  last_trip_at?: string | null;
}

export interface FaresConfig {
  km_value: number;
  min_value: number;
  min_fare_usd: number;
  uses_global_fallback: boolean;
  source?: string;
}

export interface ApiErrorBody {
  message?: string | string[];
  detail?: string;
}

export interface CreateDriverPayload {
  name: string;
  lastname: string;
  email: string;
  phone: string;
  password: string;
  image?: string | null;
}

export interface UpdateDriverPayload {
  name?: string;
  lastname?: string;
  email?: string;
  phone?: string;
  password?: string;
  image?: string | null;
}

export interface UpdateProfilePayload {
  name: string;
  lastname: string;
  phone: string;
  image?: string | null;
  password?: string;
}

export interface UpdateFaresPayload {
  km_value?: number;
  min_value?: number;
}
