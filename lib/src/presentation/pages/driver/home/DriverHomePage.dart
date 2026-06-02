import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/DriverBikeInfoPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/DriverClientRequestsPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/historyTrip/DriverHistoryTripPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/home/bloc/DriverHomeEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/home/bloc/DriverHomeBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/home/bloc/DriverHomeState.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapLocation/DriverMapLocationPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/info/ProfileInfoPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/roles/RolesPage.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  List<Widget> pageList = <Widget>[
    DriverMapLocationPage(),
    DriverClientRequestsPage(),
    DriverBikeInfoPage(),
    DriverHistoryTripPage(),
    ProfileInfoPage(),
    RolesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú de Opciones'),
        backgroundColor: const Color(0xFFFF8000),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<DriverHomeBloc, DriverHomeState>(
        builder: (context, state) {
          return pageList[state.pageIndex];
        },
      ),
      drawer: BlocBuilder<DriverHomeBloc, DriverHomeState>(
        builder: (context, state) {
          return Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8000),
                  ),
                  child: const Text(
                    'Menú del Conductor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Mapa de localización'),
                  selected: state.pageIndex == 0,
                  selectedColor: const Color(0xFFFF8000),
                  onTap: () {
                    context.read<DriverHomeBloc>().add(ChangeDrawerPage(pageIndex: 0));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Solicitudes de viaje'),
                  selected: state.pageIndex == 1,
                  selectedColor: const Color(0xFFFF8000),
                  onTap: () {
                    context.read<DriverHomeBloc>().add(ChangeDrawerPage(pageIndex: 1));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Mi Moto'),
                  selected: state.pageIndex == 2,
                  selectedColor: const Color(0xFFFF8000),
                  onTap: () {
                    context.read<DriverHomeBloc>().add(ChangeDrawerPage(pageIndex: 2));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Historial de viajes'),
                  selected: state.pageIndex == 3,
                  selectedColor: const Color(0xFFFF8000),
                  onTap: () {
                    context.read<DriverHomeBloc>().add(ChangeDrawerPage(pageIndex: 3));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Perfil del usuario'),
                  selected: state.pageIndex == 4,
                  selectedColor: const Color(0xFFFF8000),
                  onTap: () {
                    context.read<DriverHomeBloc>().add(ChangeDrawerPage(pageIndex: 4));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Roles de usuario'),
                  selected: state.pageIndex == 5,
                  selectedColor: const Color(0xFFFF8000),
                  onTap: () {
                    context.read<DriverHomeBloc>().add(ChangeDrawerPage(pageIndex: 5));
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    'Cerrar sesion',
                    style: TextStyle(color: Color(0xFFFF8000)),
                  ),
                  leading: const Icon(
                    Icons.logout,
                    color: Color(0xFFFF8000),
                  ),
                 onTap: () {
                 final blocSocketIO = context.read<BlocSocketIO>();
                  final driverHomeBloc = context.read<DriverHomeBloc>();
                  Navigator.pushNamedAndRemoveUntil(
                  context,
                  'login',
                   (route) => false,
                   );
            blocSocketIO.add(DisconnectSocketIO());
            driverHomeBloc.add(Logout());
},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}