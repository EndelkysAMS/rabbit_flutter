import 'package:flutter/material.dart';
import 'package:rabbit_flutter/src/domain/models/Role.dart';

class RolesItem extends StatelessWidget {
  final Role role;

  const RolesItem(this.role, {super.key});

  bool get _isRabbitSuper =>
      role.id == 'RABBIT_SUPER' ||
      role.name.toUpperCase().contains('RABBIT SUPER');

  bool get _isAdminLinea =>
      !_isRabbitSuper &&
      (role.id == '3' ||
      role.route == 'admin/home' ||
      role.name.toUpperCase().contains('ADMIN'));

  bool get _isDriverRole =>
      role.route == 'driver/home' ||
      role.name.toUpperCase().contains('CONDUCTOR') ||
      role.name.toUpperCase().contains('DRIVER');

  bool get _isClientRole =>
      role.route == 'client/home' ||
      role.name.toUpperCase().contains('CLIENTE') ||
      role.name.toUpperCase().contains('CLIENT');

  String _roleAsset() {
    if (_isRabbitSuper) return 'assets/img/role_admin.png';
    if (_isAdminLinea) return 'assets/img/role_admin.png';
    if (_isDriverRole) return 'assets/img/role_driver.png';
    if (_isClientRole) return 'assets/img/role_client.png';
    return 'assets/img/role_client.png';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final targetRoute = _isRabbitSuper
            ? 'super/home'
            : _isAdminLinea
                ? 'admin/home'
                : role.route;
        Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10, top: 15),
            height: 150,
            child: Image.asset(
              _roleAsset(),
              fit: BoxFit.contain,
            ),
          ),
          Text(
            role.name,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
