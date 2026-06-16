import { useQuery } from '@tanstack/react-query';
import {
  Check,
  CreditCard,
  MapPin,
  Route,
  Users,
  DollarSign,
  Mail,
  AlertTriangle,
} from 'lucide-react';
import { getDashboard } from '../api/admin';
import { formatApiError } from '../api/client';
import { PageHeader } from '../components/PageHeader';
import { StatCard, StatCardSkeleton } from '../components/StatCard';
import { PLANS } from '../config/subscription';
import {
  driversLimitLabel,
  formatSubscriptionDate,
  formatSubscriptionDateTime,
  statusLabel,
  subscriptionStatusTone,
} from '../utils/subscriptionDisplay';

export function SubscriptionPage() {
  const { data, isLoading, isError, error } = useQuery({
    queryKey: ['dashboard'],
    queryFn: getDashboard,
  });

  const sub = data?.line?.subscription;
  const plan = sub?.plan ?? 'piloto';
  const status = sub?.status ?? 'activa';
  const currentPlan = PLANS.find((p) => p.id === plan) ?? PLANS[0];

  if (isError) {
    return (
      <div className="alert alert--danger">{formatApiError(error)}</div>
    );
  }

  return (
    <div>
      <PageHeader
        title="Mi plan"
        subtitle="Suscripción y métricas de tu línea"
      />

      {data?.line?.name && (
        <div className="line-heading">
          <span className="line-heading__label">Línea</span>
          <strong className="line-heading__name">{data.line.name}</strong>
        </div>
      )}

      {status !== 'activa' && (
        <div className={`alert alert--${subscriptionStatusTone(status)} subscription-alert`}>
          <AlertTriangle size={18} />
          <div>
            <strong>{statusLabel(status)}</strong>
            <p>
              {status === 'suspendida'
                ? 'Tu línea está suspendida. Contacte con Rabbit.'
                : 'Tienes un pago pendiente. Contacte con Rabbit para evitar la suspensión.'}
            </p>
          </div>
        </div>
      )}

      <div className="subscription-current card">
        <div className="subscription-current__main">
          <p className="subscription-current__eyebrow">Plan actual</p>
          <h2>{currentPlan.name}</h2>
          <p className="text-muted">{currentPlan.description}</p>
          <div className="chip-row">
            <span className={`chip chip--${subscriptionStatusTone(status)}`}>
              {statusLabel(status)}
            </span>
            {plan === 'piloto' && sub?.days_until_pilot_end != null && (
              <span className="chip chip--warning">
                Quedan {sub.days_until_pilot_end} días de piloto
              </span>
            )}
            {sub?.max_drivers != null && (
              <span className="chip">
                Conductores{' '}
                {driversLimitLabel(
                  sub.active_drivers_count,
                  sub.max_drivers,
                )}
              </span>
            )}
            <span className="chip">{currentPlan.priceLabel}</span>
          </div>
          {!isLoading && sub && (
            <dl className="subscription-dates">
              <div>
                <dt>Último pago</dt>
                <dd>{formatSubscriptionDateTime(sub.last_payment_at)}</dd>
              </div>
              <div>
                <dt>Próximo cobro</dt>
                <dd>{formatSubscriptionDate(sub.next_billing_at)}</dd>
              </div>
              {sub.pilot_ends_at && (
                <div>
                  <dt>Fin del piloto</dt>
                  <dd>{formatSubscriptionDate(sub.pilot_ends_at)}</dd>
                </div>
              )}
            </dl>
          )}
        </div>
        <div className="subscription-current__billing">
          <CreditCard size={20} />
          <div>
            <strong>Cobro manual</strong>
            <p className="text-muted">
              La suscripción se gestiona fuera de la app (transferencia o
              factura mensual). Rabbit activa o suspende tu línea según el
              pago.
            </p>
          </div>
        </div>
      </div>

      <section className="card card--section">
        <h3>Métricas de tu línea</h3>
        <p className="text-muted subscription-section-lead">
          Datos del dashboard para valorar el plan y el uso de Rabbit.
        </p>
        <div className="stat-grid">
          {isLoading ? (
            Array.from({ length: 4 }).map((_, i) => (
              <StatCardSkeleton key={i} />
            ))
          ) : (
            <>
              <StatCard
                label="Conductores activos"
                value={data?.drivers.active ?? 0}
                icon={Users}
                tone="success"
              />
              <StatCard
                label="Con GPS"
                value={data?.drivers.with_live_position ?? 0}
                icon={MapPin}
                tone="info"
              />
              <StatCard
                label="Viajes finalizados"
                value={data?.trips.finished ?? 0}
                icon={Route}
              />
              <StatCard
                label="Ingresos registrados (USD)"
                value={`$${(data?.revenue.total_finished_usd ?? 0).toFixed(2)}`}
                icon={DollarSign}
                tone="success"
              />
            </>
          )}
        </div>
        {data && (
          <div className="chip-row" style={{ marginTop: '1rem' }}>
            <span className="chip">Viajes hoy: {data.trips.today}</span>
            <span className="chip">Total viajes: {data.trips.total}</span>
            <span className="chip">
              Ingresos hoy: $
              {(data.revenue.today_finished_usd ?? 0).toFixed(2)}
            </span>
          </div>
        )}
      </section>

      <section className="card card--section">
        <h3>Planes disponibles</h3>
        <p className="text-muted subscription-section-lead">
          Cada línea de mototaxi contrata un plan. Los viajes los cobra tu
          línea al cliente; Rabbit cobra solo la suscripción del software.
        </p>
        <div className="plan-grid">
          {PLANS.filter((p) => p.id !== 'piloto').map((planDef) => (
            <article
              key={planDef.id}
              className={`plan-card ${
                planDef.highlighted ? 'plan-card--highlighted' : ''
              } ${plan === planDef.id ? 'plan-card--current' : ''}`}
            >
              {planDef.highlighted && (
                <span className="plan-card__badge">Recomendado</span>
              )}
              {plan === planDef.id && (
                <span className="plan-card__badge plan-card__badge--current">
                  Tu plan
                </span>
              )}
              <h4>{planDef.name}</h4>
              <p className="plan-card__price">{planDef.priceLabel}</p>
              <p className="text-muted">{planDef.description}</p>
              <ul className="plan-card__features">
                {planDef.features.map((feature) => (
                  <li key={feature}>
                    <Check size={16} />
                    {feature}
                  </li>
                ))}
              </ul>
            </article>
          ))}
          <article
            className={`plan-card plan-card--piloto ${
              plan === 'piloto' ? 'plan-card--current' : ''
            }`}
          >
            {plan === 'piloto' && (
              <span className="plan-card__badge plan-card__badge--current">
                Tu plan
              </span>
            )}
            <h4>Piloto</h4>
            <p className="plan-card__price">
              {PLANS.find((p) => p.id === 'piloto')!.priceLabel}
              {sub?.days_until_pilot_end != null
                ? ` · ${sub.days_until_pilot_end} días restantes`
                : ''}
            </p>
            <p className="text-muted">
              {PLANS.find((p) => p.id === 'piloto')!.description}
            </p>
            <ul className="plan-card__features">
              {PLANS.find((p) => p.id === 'piloto')!.features.map((feature) => (
                <li key={feature}>
                  <Check size={16} />
                  {feature}
                </li>
              ))}
            </ul>
          </article>
        </div>
      </section>

      <section className="card card--section subscription-ops">
        <h3>Cómo funciona sin pago en la app</h3>
        <ol className="subscription-ops__list">
          <li>
            <strong>Plan por línea</strong> — Eliges Básico o Pro según
            conductores y reportes que necesites.
          </li>
          <li>
            <strong>Cobro manual</strong> — Rabbit te envía factura mensual;
            al confirmar el pago, tu línea queda activa en el sistema.
          </li>
          <li>
            <strong>Periodo piloto</strong> — Líneas nuevas pueden operar
            gratis durante el piloto inicial.
          </li>
          <li>
            <strong>Métricas</strong> — Usa esta página y el dashboard para
            ver viajes, conductores e ingresos y decidir si conviene subir de
            plan.
          </li>
        </ol>
        <div className="subscription-contact">
          <Mail size={18} />
          <span>
            Para cambiar de plan, renovar o reportar un pago, contacta al
            equipo Rabbit:{' '}
            <a href="mailto:soporte@rabbitapp.com">soporte@rabbitapp.com</a>
          </span>
        </div>
      </section>
    </div>
  );
}
