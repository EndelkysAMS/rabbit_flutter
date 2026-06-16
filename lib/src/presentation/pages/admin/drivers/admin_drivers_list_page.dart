import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaDriver.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_event.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_state.dart';

class AdminDriversListPage extends StatefulWidget {
  const AdminDriversListPage({super.key});

  @override
  State<AdminDriversListPage> createState() => _AdminDriversListPageState();
}

class _AdminDriversListPageState extends State<AdminDriversListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardBloc>().add(LoadDriversEvent());
    });
  }

  void _confirmDeactivate(BuildContext context, AdminLineaDriver driver) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conductores activos'),
        backgroundColor: const Color(0xFFFF8000),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () =>
                context.read<AdminDashboardBloc>().add(LoadDriversEvent()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
        listenWhen: (previous, current) =>
            previous.responseDeactivateDriver !=
                current.responseDeactivateDriver,
        listener: (context, state) {
          final deactivate = state.responseDeactivateDriver;
          if (deactivate is Success) {
            Fluttertoast.showToast(msg: 'Conductor desactivado');
            context
                .read<AdminDashboardBloc>()
                .add(ClearDeactivateDriverResponseEvent());
          } else if (deactivate is ErrorData) {
            Fluttertoast.showToast(msg: deactivate.message);
            context
                .read<AdminDashboardBloc>()
                .add(ClearDeactivateDriverResponseEvent());
          }
        },
        builder: (context, state) {
          if (state.responseDrivers is Loading ||
              state.responseDeactivateDriver is Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.drivers.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminDashboardBloc>().add(LoadDriversEvent());
              },
              child: ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(child: Text('No hay conductores activos')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminDashboardBloc>().add(LoadDriversEvent());
            },
            child: ListView.builder(
              itemCount: state.drivers.length,
              itemBuilder: (_, i) {
                final driver = state.drivers[i];
                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('${driver.name} ${driver.lastname}'),
                    subtitle: Text(
                        '${driver.email}\n${driver.phone}\nActivo: ${driver.isActive ? "Sí" : "No"}'),
                    isThreeLine: true,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0x22FF8000),
                      backgroundImage:
                          (driver.image != null && driver.image!.isNotEmpty)
                              ? NetworkImage(driver.image!)
                              : null,
                      child: (driver.image == null || driver.image!.isEmpty)
                          ? const Icon(Icons.person, color: Color(0xFFFF8000))
                          : null,
                    ),
                    trailing: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                      ),
                      onPressed: () => _confirmDeactivate(context, driver),
                      child: const Text('Desactivar'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
