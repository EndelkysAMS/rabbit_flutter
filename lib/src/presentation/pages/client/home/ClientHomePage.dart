import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/historyTrip/ClientHistoryTripPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/home/bloc/ClientHomeBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/home/bloc/ClientHomeEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/home/bloc/ClientHomeState.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapSeeker/ClientMapSeekerPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/info/ProfileInfoPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/roles/RolesPage.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  List<Widget> pageList = <Widget>[
    ClientMapSeekerPage(),
    ClientHistoryTripPage(),
    ProfileInfoPage(),
    RolesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu de opciones',
        ),
      ),
      body: BlocBuilder<ClientHomeBloc, ClientHomeState>(
        builder: (context, state) {
          return pageList[state.pageIndex];
        },
      ),
      drawer: BlocBuilder<ClientHomeBloc, ClientHomeState>(
        builder: (context, state) {
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                   color: const Color(0xFFFF8000),
                  ),
                  child: Text(
                    'Menú',
                    style: TextStyle(color: Colors.white),
                  )
                ),
                ListTile(
                  title: Text('Mapa de busqueda'),
                  selected: state.pageIndex == 0,
                  onTap: () {
                    context.read<ClientHomeBloc>().add(ChangeDrawerPage(pageIndex: 0));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Historial de viajes'),
                  selected: state.pageIndex == 1,
                  onTap: () {
                    context
                        .read<ClientHomeBloc>()
                        .add(ChangeDrawerPage(pageIndex: 1));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Perfil del usuario'),
                  selected: state.pageIndex == 2,
                  onTap: () {
                    context
                        .read<ClientHomeBloc>()
                        .add(ChangeDrawerPage(pageIndex: 2));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Roles de usuario'),
                  selected: state.pageIndex == 3,
                  onTap: () {
                    context
                        .read<ClientHomeBloc>()
                        .add(ChangeDrawerPage(pageIndex: 3));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                title: Text('Cerrar sesión'),
                onTap: () {
               final clientHomeBloc = context.read<ClientHomeBloc>();
               final blocSocketIO = context.read<BlocSocketIO>();
               Navigator.pushNamedAndRemoveUntil(
                context,
                'login',
                (route) => false,
               );
        clientHomeBloc.add(Logout());
       blocSocketIO.add(DisconnectSocketIO());
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