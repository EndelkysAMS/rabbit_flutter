import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { Plus } from 'lucide-react';
import {
  activateLine,
  createLine,
  deleteLine,
  getSuperLines,
  recordLinePayment,
  suspendLine,
} from '../../api/super';
import { formatApiError } from '../../api/client';
import type { CreateLineBody, SuperLine } from '../../types';
import { ConfirmDialog } from '../../components/ConfirmDialog';
import { DataTable, type Column } from '../../components/DataTable';
import { PageHeader } from '../../components/PageHeader';
import { CreateLineModal } from './CreateLineModal';
import {
  PlanChip,
  SubscriptionStatusChip,
} from '../../components/SubscriptionBadges';
import { PLANS, type PlanId } from '../../config/subscription';
import {
  driversLimitLabel,
  formatSubscriptionDate,
} from '../../utils/subscriptionDisplay';

interface PaymentModalProps {
  line: SuperLine | null;
  open: boolean;
  loading: boolean;
  onClose: () => void;
  onSubmit: (body: { plan: PlanId; notes: string; last_payment_at: string }) => void;
}

function PaymentModal({
  line,
  open,
  loading,
  onClose,
  onSubmit,
}: PaymentModalProps) {
  const [plan, setPlan] = useState<PlanId>('basico');
  const [notes, setNotes] = useState('');
  const [paymentAt, setPaymentAt] = useState('');

  if (!open || !line) return null;

  return (
    <div className="dialog-overlay" role="presentation" onClick={onClose}>
      <div
        className="dialog dialog--wide"
        role="dialog"
        aria-modal="true"
        onClick={(e) => e.stopPropagation()}
      >
        <h3>Registrar pago — {line.name}</h3>
        <div className="dialog__body">
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
            <span>Fecha de pago (opcional)</span>
            <input
              type="datetime-local"
              value={paymentAt}
              onChange={(e) => setPaymentAt(e.target.value)}
            />
          </label>
          <label className="field">
            <span>Notas</span>
            <textarea
              rows={3}
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Transferencia, referencia, mes facturado…"
            />
          </label>
        </div>
        <div className="dialog__actions">
          <button type="button" className="btn btn--ghost" onClick={onClose}>
            Cancelar
          </button>
          <button
            type="button"
            className="btn btn--primary"
            disabled={loading}
            onClick={() =>
              onSubmit({
                plan,
                notes,
                last_payment_at: paymentAt
                  ? new Date(paymentAt).toISOString()
                  : '',
              })
            }
          >
            {loading ? 'Guardando…' : 'Registrar pago'}
          </button>
        </div>
      </div>
    </div>
  );
}

export function SuperLinesPage() {
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const [paymentLine, setPaymentLine] = useState<SuperLine | null>(null);
  const [suspendTarget, setSuspendTarget] = useState<SuperLine | null>(null);
  const [activateTarget, setActivateTarget] = useState<SuperLine | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<SuperLine | null>(null);
  const [createLineOpen, setCreateLineOpen] = useState(false);

  const { data, isLoading, isError, error } = useQuery({
    queryKey: ['super-lines'],
    queryFn: getSuperLines,
  });

  const invalidate = () =>
    queryClient.invalidateQueries({ queryKey: ['super-lines'] });

  const paymentMutation = useMutation({
    mutationFn: ({
      id,
      body,
    }: {
      id: number;
      body: { plan: PlanId; notes: string; last_payment_at: string };
    }) =>
      recordLinePayment(id, {
        plan: body.plan,
        notes: body.notes || undefined,
        last_payment_at: body.last_payment_at || undefined,
      }),
    onSuccess: () => {
      toast.success('Pago registrado');
      setPaymentLine(null);
      invalidate();
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  const suspendMutation = useMutation({
    mutationFn: (id: number) => suspendLine(id),
    onSuccess: () => {
      toast.success('Línea suspendida');
      setSuspendTarget(null);
      invalidate();
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  const activateMutation = useMutation({
    mutationFn: (id: number) => activateLine(id),
    onSuccess: () => {
      toast.success('Línea activada');
      setActivateTarget(null);
      invalidate();
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteLine(id),
    onSuccess: (data) => {
      toast.success(data.message || 'Línea eliminada');
      setDeleteTarget(null);
      invalidate();
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  const createLineMutation = useMutation({
    mutationFn: (body: CreateLineBody) => createLine(body),
    onSuccess: (data) => {
      toast.success(data.message || 'Línea creada');
      setCreateLineOpen(false);
      invalidate();
      navigate(`/super/lines/${data.line.id}`);
    },
    onError: (err) => toast.error(formatApiError(err)),
  });

  const columns: Column<SuperLine>[] = [
    {
      key: 'name',
      header: 'Línea',
      render: (line) => (
        <Link to={`/super/lines/${line.id}`} className="table-link">
          {line.name}
        </Link>
      ),
    },
    {
      key: 'plan',
      header: 'Plan',
      render: (line) => <PlanChip plan={line.subscription.plan} />,
    },
    {
      key: 'status',
      header: 'Estado',
      render: (line) => (
        <SubscriptionStatusChip status={line.subscription.status} />
      ),
    },
    {
      key: 'drivers',
      header: 'Conductores',
      render: (line) =>
        driversLimitLabel(
          line.subscription.active_drivers_count,
          line.subscription.max_drivers,
        ),
    },
    {
      key: 'pilot',
      header: 'Piloto',
      render: (line) => {
        const days = line.subscription.days_until_pilot_end;
        if (line.subscription.plan !== 'piloto' || days == null) return '—';
        return `${days} días`;
      },
    },
    {
      key: 'next',
      header: 'Próximo cobro',
      render: (line) =>
        formatSubscriptionDate(line.subscription.next_billing_at),
    },
    {
      key: 'actions',
      header: 'Acciones',
      className: 'table-actions',
      render: (line) => (
        <div className="super-action-group">
          <button
            type="button"
            className="btn btn--super btn--super-pay"
            onClick={() => setPaymentLine(line)}
          >
            Registrar pago
          </button>
          {line.subscription.status === 'suspendida' ? (
            <button
              type="button"
              className="btn btn--super btn--super-activate"
              onClick={() => setActivateTarget(line)}
            >
              Activar
            </button>
          ) : (
            <button
              type="button"
              className="btn btn--super btn--super-danger"
              onClick={() => setSuspendTarget(line)}
            >
              Suspender
            </button>
          )}
          <Link
            to={`/super/lines/${line.id}`}
            className="btn btn--super btn--super-edit"
          >
            Ver detalle
          </Link>
          <button
            type="button"
            className="btn btn--super btn--super-danger"
            onClick={() => setDeleteTarget(line)}
          >
            Eliminar
          </button>
        </div>
      ),
    },
  ];

  return (
    <div>
      <PageHeader
        title="Líneas"
        subtitle="Suscripciones B2B2C — gestión manual de pagos"
        actions={
          <button
            type="button"
            className="btn btn--super btn--super-save"
            onClick={() => setCreateLineOpen(true)}
          >
            <Plus size={18} />
            Nueva línea piloto
          </button>
        }
      />
      {isError && (
        <div className="alert alert--danger">{formatApiError(error)}</div>
      )}
      <DataTable
        columns={columns}
        data={data ?? []}
        keyExtractor={(line) => line.id}
        loading={isLoading}
        emptyMessage="No hay líneas registradas"
      />

      <PaymentModal
        line={paymentLine}
        open={Boolean(paymentLine)}
        loading={paymentMutation.isPending}
        onClose={() => setPaymentLine(null)}
        onSubmit={(body) => {
          if (!paymentLine) return;
          paymentMutation.mutate({ id: paymentLine.id, body });
        }}
      />

      <ConfirmDialog
        open={Boolean(suspendTarget)}
        title="Suspender línea"
        message={
          suspendTarget
            ? `¿Suspender "${suspendTarget.name}"? Los conductores no podrán operar nuevos viajes.`
            : null
        }
        confirmLabel="Suspender"
        danger
        loading={suspendMutation.isPending}
        onConfirm={() => {
          if (suspendTarget) suspendMutation.mutate(suspendTarget.id);
        }}
        onCancel={() => setSuspendTarget(null)}
      />

      <ConfirmDialog
        open={Boolean(activateTarget)}
        title="Activar línea"
        message={
          activateTarget
            ? `¿Activar "${activateTarget.name}" y marcar suscripción como activa?`
            : null
        }
        confirmLabel="Activar"
        loading={activateMutation.isPending}
        onConfirm={() => {
          if (activateTarget) activateMutation.mutate(activateTarget.id);
        }}
        onCancel={() => setActivateTarget(null)}
      />

      <ConfirmDialog
        open={Boolean(deleteTarget)}
        title="Eliminar línea"
        message={
          deleteTarget
            ? `¿Eliminar permanentemente "${deleteTarget.name}"? Los usuarios quedarán sin línea asignada.`
            : null
        }
        confirmLabel="Eliminar"
        danger
        loading={deleteMutation.isPending}
        onConfirm={() => {
          if (deleteTarget) deleteMutation.mutate(deleteTarget.id);
        }}
        onCancel={() => setDeleteTarget(null)}
      />

      <CreateLineModal
        open={createLineOpen}
        loading={createLineMutation.isPending}
        onClose={() => setCreateLineOpen(false)}
        onSubmit={(body) => createLineMutation.mutate(body)}
      />
    </div>
  );
}
