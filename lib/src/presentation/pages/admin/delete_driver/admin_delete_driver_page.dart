import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaDriver.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_event.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_state.dart';

class AdminDeleteDriverPage extends StatefulWidget {
  const AdminDeleteDriverPage({super.key});

  @override
  State<AdminDeleteDriverPage> createState() => _AdminDeleteDriverPageState();
}

class _AdminDeleteDriverPageState extends State<AdminDeleteDriverPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardBloc>().add(LoadDriversEvent());
      context.read<AdminDashboardBloc>().add(LoadInactiveDriversEvent());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshAll() {
    context.read<AdminDashboardBloc>().add(LoadDriversEvent());
    context.read<AdminDashboardBloc>().add(LoadInactiveDriversEvent());
  }

  void _confirmDeactivate(BuildContext context, AdminLineaDriver driver) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Desactivar conductor'),
        content: Text(
            '¿Deseas desactivar a ${driver.name} ${driver.lastname}? Quedará inactivo pero se conserva en el sistema (acción reversible).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8000),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context
                  .read<AdminDashboardBloc>()
                  .add(DeactivateDriverEvent(idDriver: driver.id));
              Navigator.pop(context);
            },
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  void _confirmReactivate(BuildContext context, AdminLineaDriver driver) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Reactivar conductor'),
        content: Text(
            '¿Reactivar a ${driver.name} ${driver.lastname}? Volverá a operar en la línea.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8000),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context
                  .read<AdminDashboardBloc>()
                  .add(ReactivateDriverEvent(idDriver: driver.id));
              Navigator.pop(context);
            },
            child: const Text('Reactivar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminLineaDriver driver) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Eliminar definitivamente'),
        content: Text(
            'Esta acción es PERMANENTE. Se eliminará a ${driver.name} ${driver.lastname} de la línea y dejará de operar como conductor. Úsala solo si el conductor se salió de la línea.\n\n¿Deseas continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context
                  .read<AdminDashboardBloc>()
                  .add(DeleteDriverEvent(idDriver: driver.id));
              Navigator.pop(context);
            },
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eliminar conductor'),
        backgroundColor: const Color(0xFFFF8000),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Activos'),
            Tab(text: 'Inactivos'),
          ],
        ),
      ),
      body: BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
        listenWhen: (previous, current) =>
            previous.responseDeactivateDriver !=
                current.responseDeactivateDriver ||
            previous.responseDeleteDriver != current.responseDeleteDriver ||
            previous.responseReactivateDriver !=
                current.responseReactivateDriver,
        listener: (context, state) {
          final deactivate = state.responseDeactivateDriver;
          if (deactivate is Success) {
            Fluttertoast.showToast(msg: 'Conductor desactivado');
            context
                .read<AdminDashboardBloc>()
                .add(ClearDeactivateDriverResponseEvent());
            _tabController.animateTo(1);
          } else if (deactivate is ErrorData) {
            Fluttertoast.showToast(msg: deactivate.message);
            context
                .read<AdminDashboardBloc>()
                .add(ClearDeactivateDriverResponseEvent());
          }

          final delete = state.responseDeleteDriver;
          if (delete is Success) {
            Fluttertoast.showToast(
                msg: 'Conductor eliminado definitivamente de la línea');
            context
                .read<AdminDashboardBloc>()
                .add(ClearDeleteDriverResponseEvent());
          } else if (delete is ErrorData) {
            Fluttertoast.showToast(msg: delete.message);
            context
                .read<AdminDashboardBloc>()
                .add(ClearDeleteDriverResponseEvent());
          }

          final reactivate = state.responseReactivateDriver;
          if (reactivate is Success) {
            Fluttertoast.showToast(msg: 'Conductor reactivado');
            context
                .read<AdminDashboardBloc>()
                .add(ClearReactivateDriverResponseEvent());
            _tabController.animateTo(0);
          } else if (reactivate is ErrorData) {
            Fluttertoast.showToast(msg: reactivate.message);
            context
                .read<AdminDashboardBloc>()
                .add(ClearReactivateDriverResponseEvent());
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _ActiveDriversTab(
                state: state,
                onRefresh: _refreshAll,
                onDeactivate: (driver) => _confirmDeactivate(context, driver),
              ),
              _InactiveDriversTab(
                state: state,
                onRefresh: _refreshAll,
                onReactivate: (driver) => _confirmReactivate(context, driver),
                onDelete: (driver) => _confirmDelete(context, driver),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActiveDriversTab extends StatelessWidget {
  final AdminDashboardState state;
  final VoidCallback onRefresh;
  final void Function(AdminLineaDriver driver) onDeactivate;

  const _ActiveDriversTab({
    required this.state,
    required this.onRefresh,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = state.responseDrivers is Loading ||
        state.responseDeactivateDriver is Loading;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderBanner(
            text:
                'Conductores activos. Desactívalos si dejan de operar en la línea.',
          ),
          const SizedBox(height: 14),
          if (isBusy)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.drivers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text('No hay conductores activos')),
            )
          else
            ...state.drivers.map(
              (driver) => _DriverCard(
                driver: driver,
                action: OutlinedButton.icon(
                  onPressed: () => onDeactivate(driver),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF8000),
                    side: const BorderSide(color: Color(0xFFFF8000)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.pause_circle_outline, size: 18),
                  label: const Text('Desactivar'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InactiveDriversTab extends StatelessWidget {
  final AdminDashboardState state;
  final VoidCallback onRefresh;
  final void Function(AdminLineaDriver driver) onReactivate;
  final void Function(AdminLineaDriver driver) onDelete;

  const _InactiveDriversTab({
    required this.state,
    required this.onRefresh,
    required this.onReactivate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = state.responseInactiveDrivers is Loading ||
        state.responseReactivateDriver is Loading ||
        state.responseDeleteDriver is Loading;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderBanner(
            text:
                'Conductores inactivos. Reactívalos para que vuelvan a operar, o elimínalos definitivamente si se salieron de la línea.',
          ),
          const SizedBox(height: 14),
          if (isBusy)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.inactiveDrivers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text('No hay conductores inactivos')),
            )
          else
            ...state.inactiveDrivers.map(
              (driver) => _DriverCard(
                driver: driver,
                action: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => onReactivate(driver),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF8000),
                          side: const BorderSide(color: Color(0xFFFF8000)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.play_circle_outline, size: 18),
                        label: const Text('Reactivar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onDelete(driver),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Eliminar definitivamente'),
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

class _HeaderBanner extends StatelessWidget {
  final String text;

  const _HeaderBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8000),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final AdminLineaDriver driver;
  final Widget action;

  const _DriverCard({
    required this.driver,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0x22FF8000),
                  backgroundImage:
                      (driver.image != null && driver.image!.isNotEmpty)
                          ? NetworkImage(driver.image!)
                          : null,
                  child: (driver.image == null || driver.image!.isEmpty)
                      ? const Icon(Icons.person, color: Color(0xFFFF8000))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${driver.name} ${driver.lastname}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(driver.email,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13)),
                      Text(driver.phone,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13)),
                      Text(
                        'Activo: ${driver.isActive ? "Sí" : "No"}',
                        style: TextStyle(
                          color: driver.isActive
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            action,
          ],
        ),
      ),
    );
  }
}
