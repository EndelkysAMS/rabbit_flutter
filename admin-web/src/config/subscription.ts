export type PlanId = 'piloto' | 'basico' | 'pro';
export type SubscriptionStatus = 'activa' | 'morosa' | 'suspendida';

export interface PlanDefinition {
  id: PlanId;
  name: string;
  priceLabel: string;
  description: string;
  features: string[];
  highlighted?: boolean;
}

export const PLANS: PlanDefinition[] = [
  {
    id: 'piloto',
    name: 'Piloto',
    priceLabel: '$0 USD / 3 meses',
    description: 'Prueba gratuita para líneas nuevas en Rabbit.',
    features: ['Panel admin de línea', 'Hasta 10 conductores'],
  },
  {
    id: 'basico',
    name: 'Básico',
    priceLabel: '$20 USD / mes',
    description: 'Operación diaria de tu línea con lo esencial.',
    features: ['Conductores ilimitados', 'Mapa GPS en tiempo real'],
  },
  {
    id: 'pro',
    name: 'Pro',
    priceLabel: '$30 USD / mes',
    description: 'Para líneas con mayor volumen de viajes.',
    highlighted: true,
    features: ['Reportes de ingresos', 'Soporte prioritario'],
  },
];

/** Valor por defecto hasta que el backend exponga suscripción por línea. */
export const DEFAULT_SUBSCRIPTION = {
  plan: 'piloto' as PlanId,
  status: 'activa' as SubscriptionStatus,
  pilotMonths: 3,
};

export const PLAN_LABELS: Record<PlanId, string> = {
  piloto: 'Piloto',
  basico: 'Básico',
  pro: 'Pro',
};

export const STATUS_LABELS: Record<SubscriptionStatus, string> = {
  activa: 'Activa',
  morosa: 'Pago pendiente',
  suspendida: 'Suspendida',
};
