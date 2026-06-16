import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { ArrowLeft } from 'lucide-react';
import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import toast from 'react-hot-toast';
import {
  activateLine,
  deleteLine,
  getSuperLines,
  patchLineSubscription,
  recordLinePayment,
  suspendLine,
} from '../../api/super';
import { formatApiError } from '../../api/client';
import { ConfirmDialog } from '../../components/ConfirmDialog';
import { PageHeader } from '../../components/PageHeader';
import { SuperLineAdminsSection } from './SuperLineAdminsSection';
import {
  PlanChip,
  SubscriptionStatusChip,
} from '../../components/SubscriptionBadges';
import { PLANS, type PlanId, type SubscriptionStatus } from '../../config/subscription';
import {
  driversLimitLabel,
  formatSubscriptionDate,
  formatSubscriptionDateTime,
  planLabel,
} from '../../utils/subscriptionDisplay';

export function SuperLineDetailPage() {
  const { id } = useParams();
  const lineId = Number(id);
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  const [plan, setPlan] = useState<PlanId>('piloto');
  const [status, setStatus] = useState<SubscriptionStatus>('activa');
  const [notes, setNotes] = useState('');
  const [nextBillingAt, setNextBillingAt] = useState('');
  const [lastPaymentAt, setLastPaymentAt] = useState('');
  const [paymentPlan, setPaymentPlan] = useState<PlanId>('basico');
  const [paymentNotes, setPaymentNotes] = useState('');
  const [paymentAt, setPaymentAt] = useState('');
  const [confirmSuspend, setConfirmSuspend] = useState(false);
  const [confirmActivate, setConfirmActivate] = useState(false);
  const [confirmPayment, setConfirmPayment] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);

  const { data: lines, isLoading, isError, error } = useQuery({
    queryKey: ['super-lines'],
    queryFn: getSuperLines,
  });

  const line = lines?.find((item) => item.id === lineId);

  useEffect(() => {
    if (!line) return;
    const sub = line.subscription;
    setPlan(sub.plan);
    setStatus(sub.status);
    setNotes(sub.notes ?? '');
    setNextBillingAt(toLocalInputValue(sub.next_billing_at));
    setLastPaymentAt(toLocalInputValue(sub.last_payment_at));
    setPaymentPlan(sub.plan === 'piloto' ? 'basico' : sub.plan);
  }, [line]);

  const invalidate = () =>
    queryClient.invalidateQueries({ queryKey: ['super-lines'] });

  const patchMutation = useMutation({
    mutationFn: () =>
      patchLineSubscription(lineId, {
        plan,
        status,
        notes,
        next_billing_at: nextBillingAt
          ? new Date(nextBillingAt).toISOString()
          : null,
        last_payment_at: lastPaymentAt
          ? new Date(lastPaymentAt).toISOString()
          : null,
      }),
    onSuccess: () => {
      toast.success('Suscripción actualizada');
      invalidate();
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  const paymentMutation = useMutation({
    mutationFn: () =>
      recordLinePayment(lineId, {
        plan: paymentPlan,
        notes: paymentNotes || undefined,
        last_payment_at: paymentAt
          ? new Date(paymentAt).toISOString()
          : undefined,
      }),
    onSuccess: () => {
      toast.success('Pago registrado');
      setConfirmPayment(false);
      invalidate();
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  const suspendMutation = useMutation({
    mutationFn: () => suspendLine(lineId),
    onSuccess: () => {
      toast.success('Línea suspendida');
      setConfirmSuspend(false);
      invalidate();
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  const activateMutation = useMutation({
    mutationFn: () => activateLine(lineId),
    onSuccess: () => {
      toast.success('Línea activada');
      setConfirmActivate(false);
      invalidate();
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  const deleteMutation = useMutation({
    mutationFn: () => deleteLine(lineId),
    onSuccess: (data) => {
      toast.success(data.message || 'Línea eliminada');
      setConfirmDelete(false);
      invalidate();
      navigate('/super/lines');
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  if (isLoading) {
    return <div className="alert alert--info">Cargando línea…</div>;
  }

  if (isError) {
    return (
      <div className="alert alert--danger">{formatApiError(error)}</div>
    );
  }

  if (!line) {
    return (
      <div className="alert alert--danger">
        Línea no encontrada.{' '}
        <Link to="/super/lines">Volver al listado</Link>
      </div>
    );
  }

  const sub = line.subscription;

  return (
    <div>
      <PageHeader
        title={line.name}
        subtitle={`Línea #${line.id} — ${planLabel(sub.plan)}`}
        actions={
          <Link to="/super/lines" className="btn btn--super btn--super-edit">
            <ArrowLeft size={18} />
            Volver
          </Link>
        }
      />

      <div className="card card--section super-line-summary">
        <div className="chip-row">
          <PlanChip plan={sub.plan} />
          <SubscriptionStatusChip status={sub.status} />
          <span className="chip">
            Conductores{' '}
            {driversLimitLabel(
              sub.active_drivers_count,
              sub.max_drivers,
            )}
          </span>
          {sub.plan === 'piloto' && sub.days_until_pilot_end != null && (
            <span className="chip chip--warning">
              Piloto: {sub.days_until_pilot_end} días restantes
            </span>
          )}
        </div>
        <dl className="detail-grid">
          <div>
            <dt>Inicio</dt>
            <dd>{formatSubscriptionDateTime(sub.started_at)}</dd>
          </div>
          <div>
            <dt>Fin piloto</dt>
            <dd>{formatSubscriptionDate(sub.pilot_ends_at)}</dd>
          </div>
          <div>
            <dt>Último pago</dt>
            <dd>{formatSubscriptionDateTime(sub.last_payment_at)}</dd>
          </div>
          <div>
            <dt>Próximo cobro</dt>
            <dd>{formatSubscriptionDate(sub.next_billing_at)}</dd>
          </div>
          <div>
            <dt>Creada</dt>
            <dd>{formatSubscriptionDateTime(line.created_at)}</dd>
          </div>
          <div>
            <dt>Actualizada</dt>
            <dd>{formatSubscriptionDateTime(line.updated_at)}</dd>
          </div>
        </dl>
      </div>

      <SuperLineAdminsSection lineId={lineId} lineName={line.name} />

      <div className="super-detail-grid">
        <section className="card card--section">
          <h3>Editar suscripción</h3>
          <form
            className="form-grid"
            onSubmit={(e) => {
              e.preventDefault();
              patchMutation.mutate();
            }}
          >
            <label className="field">
              <span>Plan</span>
              <select
                value={plan}
                onChange={(e) => setPlan(e.target.value as PlanId)}
              >
                {PLANS.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name}
                  </option>
                ))}
              </select>
            </label>
            <label className="field">
              <span>Estado</span>
              <select
                value={status}
                onChange={(e) =>
                  setStatus(e.target.value as SubscriptionStatus)
                }
              >
                <option value="activa">Activa</option>
                <option value="morosa">Morosa</option>
                <option value="suspendida">Suspendida</option>
              </select>
            </label>
            <label className="field">
              <span>Próximo cobro</span>
              <input
                type="datetime-local"
                value={nextBillingAt}
                onChange={(e) => setNextBillingAt(e.target.value)}
              />
            </label>
            <label className="field">
              <span>Último pago</span>
              <input
                type="datetime-local"
                value={lastPaymentAt}
                onChange={(e) => setLastPaymentAt(e.target.value)}
              />
            </label>
            <label className="field field--full">
              <span>Notas internas</span>
              <textarea
                rows={4}
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
              />
            </label>
            <div className="field field--full super-form-actions">
              <button
                type="submit"
                className="btn btn--super btn--super-save"
                disabled={patchMutation.isPending}
              >
                {patchMutation.isPending ? 'Guardando…' : 'Guardar cambios'}
              </button>
            </div>
          </form>
        </section>

        <section className="card card--section">
          <h3>Acciones rápidas</h3>
          <p className="text-muted">
            Cobro manual fuera de la app. Registrar pago activa la línea y
            actualiza fechas automáticamente.
          </p>
          <div className="super-actions">
            <label className="field">
              <span>Plan al registrar pago</span>
              <select
                value={paymentPlan}
                onChange={(e) => setPaymentPlan(e.target.value as PlanId)}
              >
                {PLANS.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name}
                  </option>
                ))}
              </select>
            </label>
            <label className="field">
              <span>Fecha de pago (opcional)</span>
              <input
                type="datetime-local"
                value={paymentAt}
                onChange={(e) => setPaymentAt(e.target.value)}
              />
            </label>
            <label className="field">
              <span>Notas del pago</span>
              <textarea
                rows={3}
                value={paymentNotes}
                onChange={(e) => setPaymentNotes(e.target.value)}
              />
            </label>
            <div className="super-action-group super-action-group--wide">
              <button
                type="button"
                className="btn btn--super btn--super-pay"
                onClick={() => setConfirmPayment(true)}
              >
                Registrar pago
              </button>
              {sub.status === 'suspendida' ? (
                <button
                  type="button"
                  className="btn btn--super btn--super-activate"
                  onClick={() => setConfirmActivate(true)}
                >
                  Activar línea
                </button>
              ) : (
                <button
                  type="button"
                  className="btn btn--super btn--super-danger"
                  onClick={() => setConfirmSuspend(true)}
                >
                  Suspender línea
                </button>
              )}
            </div>
          </div>
        </section>
      </div>

      <section className="card card--section super-line-danger-zone">
        <h3>Eliminar línea</h3>
        <p className="text-muted">
          Si la línea decide salir de Rabbit, puedes eliminarla del sistema.
          Se borrarán la suscripción y tarifas; los usuarios (admin y conductores)
          quedarán sin línea asignada.
        </p>
        <button
          type="button"
          className="btn btn--super btn--super-danger"
          onClick={() => setConfirmDelete(true)}
        >
          Eliminar línea
        </button>
      </section>

      <ConfirmDialog
        open={confirmPayment}
        title="Registrar pago"
        message={`¿Confirmar pago manual para "${line.name}"?`}
        loading={paymentMutation.isPending}
        onConfirm={() => paymentMutation.mutate()}
        onCancel={() => setConfirmPayment(false)}
      />
      <ConfirmDialog
        open={confirmSuspend}
        title="Suspender línea"
        message={`¿Suspender "${line.name}"?`}
        confirmLabel="Suspender"
        danger
        loading={suspendMutation.isPending}
        onConfirm={() => suspendMutation.mutate()}
        onCancel={() => setConfirmSuspend(false)}
      />
      <ConfirmDialog
        open={confirmActivate}
        title="Activar línea"
        message={`¿Activar "${line.name}"?`}
        confirmLabel="Activar"
        loading={activateMutation.isPending}
        onConfirm={() => activateMutation.mutate()}
        onCancel={() => setConfirmActivate(false)}
      />
      <ConfirmDialog
        open={confirmDelete}
        title="Eliminar línea"
        message={`¿Eliminar permanentemente "${line.name}"? Esta acción no se puede deshacer.`}
        confirmLabel="Eliminar línea"
        danger
        loading={deleteMutation.isPending}
        onConfirm={() => deleteMutation.mutate()}
        onCancel={() => setConfirmDelete(false)}
      />
    </div>
  );
}

function toLocalInputValue(value?: string | null): string {
  if (!value) return '';
  const date = new Date(value);
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}
