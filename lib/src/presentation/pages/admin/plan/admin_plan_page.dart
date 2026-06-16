import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaDashboard.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLineSubscription.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_event.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_state.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/plan/admin_linea_plan_config.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/super_subscription_helpers.dart';

const _orange = Color(0xFFFF8000);
const _supportEmail = 'soporte@rabbitapp.com';

class AdminPlanPage extends StatefulWidget {
  const AdminPlanPage({super.key});

  @override
  State<AdminPlanPage> createState() => _AdminPlanPageState();
}

class _AdminPlanPageState extends State<AdminPlanPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardBloc>().add(LoadAdminPlanEvent());
    });
  }

  void _copySupportEmail() {
    Clipboard.setData(const ClipboardData(text: _supportEmail));
    Fluttertoast.showToast(msg: 'Correo copiado: $_supportEmail');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi plan'),
        backgroundColor: _orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () =>
                context.read<AdminDashboardBloc>().add(LoadAdminPlanEvent()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
        listenWhen: (previous, current) => previous.didLogout != current.didLogout,
        listener: (context, state) {
          if (state.didLogout) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'login',
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          final response = state.responseDashboard;
          if (response is Loading && state.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (response is ErrorData && state.dashboard == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(response.message, textAlign: TextAlign.center),
              ),
            );
          }

          final dashboard = state.dashboard;
          if (dashboard == null) {
            return const Center(child: Text('No hay datos de suscripción'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminDashboardBloc>().add(LoadAdminPlanEvent());
              await Future<void>.delayed(const Duration(milliseconds: 400));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _LineHeading(name: dashboard.line.name),
                _StatusAlert(subscription: dashboard.line.subscription),
                _CurrentPlanCard(dashboard: dashboard),
                const SizedBox(height: 16),
                _AvailablePlansSection(
                  currentPlanId: dashboard.line.subscription.plan,
                  subscription: dashboard.line.subscription,
                  onContact: _copySupportEmail,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LineHeading extends StatelessWidget {
  final String name;

  const _LineHeading({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x59FF8000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Línea',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusAlert extends StatelessWidget {
  final SuperLineSubscription subscription;

  const _StatusAlert({required this.subscription});

  @override
  Widget build(BuildContext context) {
    if (subscription.status == 'activa') return const SizedBox.shrink();

    final isSuspended = subscription.status == 'suspendida';
    final bg = isSuspended
        ? statusColor('suspendida').withValues(alpha: 0.12)
        : statusColor('morosa').withValues(alpha: 0.12);
    final accent =
        isSuspended ? statusColor('suspendida') : statusColor('morosa');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adminLineaStatusLabel(subscription.status),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSuspended
                      ? 'Tu línea está suspendida. Contacte con Rabbit.'
                      : 'Tienes un pago pendiente. Contacte con Rabbit para evitar la suspensión.',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final AdminLineaDashboard dashboard;

  const _CurrentPlanCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final sub = dashboard.line.subscription;
    final planDef = adminLineaPlanById(sub.plan);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x59FF8000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan actual',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            planDef.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            planDef.description,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label: adminLineaStatusLabel(sub.status),
                color: statusColor(sub.status),
              ),
              if (sub.plan == 'piloto' && sub.daysUntilPilotEnd != null)
                _Chip(
                  label: 'Quedan ${sub.daysUntilPilotEnd} días de piloto',
                  color: const Color(0xFFE6A817),
                ),
              if (sub.maxDrivers != null)
                _Chip(
                  label: 'Conductores ${driversLimitLabel(sub)}',
                  color: Colors.blueGrey,
                ),
              _Chip(label: planDef.priceLabel, color: _orange),
            ],
          ),
          const SizedBox(height: 14),
          _DateRow(
            label: 'Último pago',
            value: formatSubscriptionDateTime(sub.lastPaymentAt),
          ),
          _DateRow(
            label: 'Próximo cobro',
            value: formatSubscriptionDate(sub.nextBillingAt),
          ),
          if (sub.pilotEndsAt != null && sub.pilotEndsAt!.isNotEmpty)
            _DateRow(
              label: 'Fin del piloto',
              value: formatSubscriptionDate(sub.pilotEndsAt),
            ),
          const Divider(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.credit_card, color: _orange, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Cobro manual',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'La suscripción se gestiona fuera de la app (transferencia o factura mensual). Rabbit activa o suspende tu línea según el pago.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailablePlansSection extends StatelessWidget {
  final String currentPlanId;
  final SuperLineSubscription subscription;
  final VoidCallback onContact;

  const _AvailablePlansSection({
    required this.currentPlanId,
    required this.subscription,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Planes disponibles',
      subtitle:
          'Cada línea de mototaxi contrata un plan. Los viajes los cobra tu línea al cliente; Rabbit cobra solo la suscripción del software.',
      child: Column(
        children: [
          ...adminLineaPlans.map((planDef) {
            final isCurrent = planDef.id == currentPlanId;
            return _PlanCard(
              planDef: planDef,
              isCurrent: isCurrent,
              pilotDaysLeft: subscription.daysUntilPilotEnd,
            );
          }),
          const SizedBox(height: 8),
          InkWell(
            onTap: onContact,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x59FF8000)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline, color: _orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Para cambiar de plan, renovar o reportar un pago: ',
                          ),
                          TextSpan(
                            text: _supportEmail,
                            style: const TextStyle(
                              color: _orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

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
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final AdminLineaPlanDefinition planDef;
  final bool isCurrent;
  final int? pilotDaysLeft;

  const _PlanCard({
    required this.planDef,
    required this.isCurrent,
    this.pilotDaysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final price = planDef.id == 'piloto'
        ? (pilotDaysLeft != null
            ? '${planDef.priceLabel} · $pilotDaysLeft días restantes'
            : planDef.priceLabel)
        : planDef.priceLabel;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFFFF4E8) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? _orange
              : planDef.highlighted
                  ? const Color(0x592563EB)
                  : const Color(0x22000000),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (planDef.highlighted)
                const _Badge(label: 'Recomendado', color: Color(0xFF2563EB)),
              if (isCurrent) const _Badge(label: 'Tu plan', color: _orange),
            ],
          ),
          Text(
            planDef.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: _orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            planDef.description,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ...planDef.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, size: 16, color: _orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(feature, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String value;

  const _DateRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
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
    final accent = color ?? Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
