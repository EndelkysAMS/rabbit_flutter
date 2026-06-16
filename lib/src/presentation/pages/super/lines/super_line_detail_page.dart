import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLine.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/dashboard/bloc/super_dashboard_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/dashboard/bloc/super_dashboard_event.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/dashboard/bloc/super_dashboard_state.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/super_subscription_helpers.dart';

class SuperLineDetailPage extends StatefulWidget {
  final int lineId;

  const SuperLineDetailPage({super.key, required this.lineId});

  @override
  State<SuperLineDetailPage> createState() => _SuperLineDetailPageState();
}

class _SuperLineDetailPageState extends State<SuperLineDetailPage> {
  String? _plan;
  String? _status;
  final _notesController = TextEditingController();
  String _paymentPlan = 'basico';
  final _paymentNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<SuperDashboardBloc>();
      if (bloc.state.lines.isEmpty) {
        bloc.add(LoadSuperLinesEvent());
      } else {
        _syncFromLine(bloc.state.lineById(widget.lineId));
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _paymentNotesController.dispose();
    super.dispose();
  }

  void _syncFromLine(SuperLine? line) {
    if (line == null) return;
    _plan = line.subscription.plan;
    _status = line.subscription.status;
    _notesController.text = line.subscription.notes ?? '';
    _paymentPlan =
        line.subscription.plan == 'piloto' ? 'basico' : line.subscription.plan;
  }

  void _saveSubscription() {
    context.read<SuperDashboardBloc>().add(
          PatchSuperLineSubscriptionEvent(
            lineId: widget.lineId,
            plan: _plan,
            status: _status,
            notes: _notesController.text.trim(),
          ),
        );
  }

  void _recordPayment() {
    context.read<SuperDashboardBloc>().add(
          RecordSuperLinePaymentEvent(
            lineId: widget.lineId,
            plan: _paymentPlan,
            notes: _paymentNotesController.text.trim(),
          ),
        );
  }

  void _toggleSuspend(SuperLine line) {
    final isSuspended = line.subscription.status == 'suspendida';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isSuspended ? 'Activar línea' : 'Suspender línea'),
        content: Text(
          isSuspended
              ? '¿Activar "${line.name}"?'
              : '¿Suspender "${line.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSuspended ? statusColor('activa') : statusColor('suspendida'),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<SuperDashboardBloc>().add(
                    isSuspended
                        ? ActivateSuperLineEvent(lineId: widget.lineId)
                        : SuspendSuperLineEvent(lineId: widget.lineId),
                  );
              Navigator.pop(dialogContext);
            },
            child: Text(isSuspended ? 'Activar' : 'Suspender'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SuperLine line) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar línea'),
        content: Text(
          '¿Eliminar permanentemente "${line.name}"? '
          'Se borrarán suscripción y tarifas. Los usuarios quedarán sin línea asignada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: statusColor('suspendida'),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context
                  .read<SuperDashboardBloc>()
                  .add(DeleteSuperLineEvent(lineId: widget.lineId));
              Navigator.pop(dialogContext);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de línea'),
        backgroundColor: superOrange,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SuperDashboardBloc, SuperDashboardState>(
        listenWhen: (previous, current) =>
            previous.responseAction != current.responseAction ||
            previous.lines != current.lines ||
            previous.lastDeletedLineId != current.lastDeletedLineId,
        listener: (context, state) {
          if (state.lastDeletedLineId == widget.lineId) {
            Fluttertoast.showToast(msg: 'Línea eliminada');
            context
                .read<SuperDashboardBloc>()
                .add(ClearSuperActionResponseEvent());
            Navigator.pop(context);
            return;
          }

          final line = state.lineById(widget.lineId);
          if (line != null && (_plan == null || _status == null)) {
            _syncFromLine(line);
            setState(() {});
          }

          final action = state.responseAction;
          if (action is Success) {
            Fluttertoast.showToast(msg: 'Operación completada');
            _syncFromLine(state.lineById(widget.lineId));
            setState(() {});
            context
                .read<SuperDashboardBloc>()
                .add(ClearSuperActionResponseEvent());
          } else if (action is ErrorData) {
            Fluttertoast.showToast(msg: action.message);
            context
                .read<SuperDashboardBloc>()
                .add(ClearSuperActionResponseEvent());
          }
        },
        builder: (context, state) {
          final line = state.lineById(widget.lineId);
          if (state.responseLines is Loading && line == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (line == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Línea no encontrada'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          final sub = line.subscription;
          if (_plan == null || _status == null) {
            _syncFromLine(line);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x59FF8000)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Línea #${line.id} — ${planLabel(sub.plan)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(
                          label: planLabel(sub.plan),
                          color: superOrange,
                        ),
                        _Badge(
                          label: statusLabel(sub.status),
                          color: statusColor(sub.status),
                        ),
                        _Badge(
                          label: 'Conductores ${driversLimitLabel(sub)}',
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _detailRow('Inicio', formatSubscriptionDateTime(sub.startedAt)),
                    _detailRow('Fin piloto', formatSubscriptionDate(sub.pilotEndsAt)),
                    _detailRow(
                      'Último pago',
                      formatSubscriptionDateTime(sub.lastPaymentAt),
                    ),
                    _detailRow(
                      'Próximo cobro',
                      formatSubscriptionDate(sub.nextBillingAt),
                    ),
                    _detailRow(
                      'Creada',
                      formatSubscriptionDateTime(line.createdAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Editar suscripción',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: superPlans.contains(_plan) ? _plan : 'piloto',
                      decoration: const InputDecoration(labelText: 'Plan'),
                      items: superPlans
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(planLabel(p)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _plan = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: superStatuses.contains(_status) ? _status : 'activa',
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: superStatuses
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(statusLabel(s)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _status = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Notas internas',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: superOrange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: state.responseAction is Loading
                            ? null
                            : _saveSubscription,
                        child: state.responseAction is Loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Guardar cambios'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Acciones rápidas',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Cobro manual fuera de la app. Registrar pago activa la línea y actualiza fechas.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: superPlans.contains(_paymentPlan)
                          ? _paymentPlan
                          : 'basico',
                      decoration:
                          const InputDecoration(labelText: 'Plan al registrar pago'),
                      items: superPlans
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(planLabel(p)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _paymentPlan = value ?? 'basico'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _paymentNotesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notas del pago',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: state.responseAction is Loading
                          ? null
                          : _recordPayment,
                      child: const Text('Registrar pago'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sub.status == 'suspendida'
                            ? statusColor('activa')
                            : statusColor('suspendida'),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: state.responseAction is Loading
                          ? null
                          : () => _toggleSuspend(line),
                      child: Text(
                        sub.status == 'suspendida'
                            ? 'Activar línea'
                            : 'Suspender línea',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Eliminar línea',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Si la línea decide salir de Rabbit, puedes eliminarla del sistema. '
                      'Los usuarios (admin y conductores) quedarán sin línea asignada.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor('suspendida'),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: state.responseAction is Loading
                          ? null
                          : () => _confirmDelete(line),
                      child: const Text('Eliminar línea'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
