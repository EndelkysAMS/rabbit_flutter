import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_event.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_state.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardBloc>().add(AdminDashboardInitEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        backgroundColor: const Color(0xFFFF8000),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFFF8000),
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: const Text('Crear conductor'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'admin/drivers/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups),
              title: const Text('Conductores activos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'admin/drivers/list');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_alt_1),
              title: const Text('Eliminar conductor'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'admin/drivers/delete');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Mi plan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'admin/plan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'admin/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Roles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, 'roles', (route) => false);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Color(0xFFFF8000),
              ),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Color(0xFFFF8000)),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<AdminDashboardBloc>().add(LogoutAdminEvent());
              },
            ),
          ],
        ),
      ),
      body: BlocListener<AdminDashboardBloc, AdminDashboardState>(
        listener: (context, state) {
          if (state.didLogout) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'login',
              (route) => false,
            );
            return;
          }
        },
        child: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8000),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienvenido',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${state.adminUser?.name ?? ''} ${state.adminUser?.lastname ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.adminUser?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Accesos rápidos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.person_add_alt_1,
                        title: 'Crear conductor',
                        onTap: () =>
                            Navigator.pushNamed(context, 'admin/drivers/create'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.groups,
                        title: 'Conductores',
                        onTap: () =>
                            Navigator.pushNamed(context, 'admin/drivers/list'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.credit_card,
                        title: 'Mi plan',
                        onTap: () =>
                            Navigator.pushNamed(context, 'admin/plan'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.person,
                        title: 'Perfil',
                        onTap: () =>
                            Navigator.pushNamed(context, 'admin/profile'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.badge,
                        title: 'Roles',
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context, 'roles', (route) => false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
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
          children: [
            Icon(icon, size: 28, color: const Color(0xFFFF8000)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

