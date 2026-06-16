import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLine.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/dashboard/bloc/super_dashboard_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/dashboard/bloc/super_dashboard_event.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/dashboard/bloc/super_dashboard_state.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/super_subscription_helpers.dart';

class SuperLinesListPage extends StatefulWidget {
  const SuperLinesListPage({super.key});

  @override
  State<SuperLinesListPage> createState() => _SuperLinesListPageState();
}

class _SuperLinesListPageState extends State<SuperLinesListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuperDashboardBloc>().add(LoadSuperLinesEvent());
    });
  }

  void _showPaymentDialog(SuperLine line) {
    var selectedPlan = line.subscription.plan == 'piloto'
        ? 'basico'
        : line.subscription.plan;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Registrar pago — ${line.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: superPlans.contains(selectedPlan) ? selectedPlan : 'basico',
                decoration: const InputDecoration(labelText: 'Plan'),
                items: superPlans
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(planLabel(p)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedPlan = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  hintText: 'Transferencia, referencia…',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: superOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<SuperDashboardBloc>().add(
                    RecordSuperLinePaymentEvent(
                      lineId: line.id,
                      plan: selectedPlan,
                      notes: notesController.text.trim(),
                    ),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  void _confirmSuspend(SuperLine line) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Suspender línea'),
        content: Text(
          '¿Suspender "${line.name}"? Los conductores no podrán operar nuevos viajes.',
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
                  .add(SuspendSuperLineEvent(lineId: line.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Suspender'),
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
          'Los usuarios quedarán sin línea asignada.',
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
                  .add(DeleteSuperLineEvent(lineId: line.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmActivate(SuperLine line) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Activar línea'),
        content: Text('¿Activar "${line.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: statusColor('activa'),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context
                  .read<SuperDashboardBloc>()
                  .add(ActivateSuperLineEvent(lineId: line.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Activar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Líneas'),
        backgroundColor: superOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () =>
                context.read<SuperDashboardBloc>().add(LoadSuperLinesEvent()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<SuperDashboardBloc, SuperDashboardState>(
        listenWhen: (previous, current) =>
            previous.responseAction != current.responseAction,
        listener: (context, state) {
          final action = state.responseAction;
          if (action is Success) {
            final msg = state.lastDeletedLineId != null
                ? 'Línea eliminada'
                : 'Operación completada';
            Fluttertoast.showToast(msg: msg);
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
          final linesResponse = state.responseLines;
          if (linesResponse is Loading && state.lines.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (linesResponse is ErrorData && state.lines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(linesResponse.message, textAlign: TextAlign.center),
              ),
            );
          }
          if (state.lines.isEmpty) {
            return const Center(child: Text('No hay líneas registradas'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.lines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final line = state.lines[index];
              final sub = line.subscription;
              final isSuspended = sub.status == 'suspendida';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.pushNamed(
                    context,
                    'super/lines/detail',
                    arguments: line.id,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                line.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _Chip(label: planLabel(sub.plan)),
                            const SizedBox(width: 6),
                            _Chip(
                              label: statusLabel(sub.status),
                              color: statusColor(sub.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Conductores: ${driversLimitLabel(sub)}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        if (sub.plan == 'piloto' &&
                            sub.daysUntilPilotEnd != null)
                          Text(
                            'Piloto: ${sub.daysUntilPilotEnd} días restantes',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        Text(
                          'Próximo cobro: ${formatSubscriptionDate(sub.nextBillingAt)}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ActionButton(
                              label: 'Pago',
                              color: const Color(0xFF2563EB),
                              onPressed: () => _showPaymentDialog(line),
                            ),
                            _ActionButton(
                              label: isSuspended ? 'Activar' : 'Suspender',
                              color: isSuspended
                                  ? statusColor('activa')
                                  : statusColor('suspendida'),
                              onPressed: () => isSuspended
                                  ? _confirmActivate(line)
                                  : _confirmSuspend(line),
                            ),
                            _ActionButton(
                              label: 'Detalle',
                              color: superOrange,
                              onPressed: () => Navigator.pushNamed(
                                context,
                                'super/lines/detail',
                                arguments: line.id,
                              ),
                            ),
                            _ActionButton(
                              label: 'Eliminar',
                              color: statusColor('suspendida'),
                              onPressed: () => _confirmDelete(line),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;

  const _Chip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final accent = color ?? superOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
