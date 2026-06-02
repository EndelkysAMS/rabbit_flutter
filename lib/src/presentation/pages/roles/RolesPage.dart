import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/domain/models/Role.dart';
import 'package:rabbit_flutter/src/presentation/pages/roles/RolesItem.dart';
import 'package:rabbit_flutter/src/presentation/pages/roles/bloc/RolesBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/roles/bloc/RolesState.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RolesBloc, RolesState>(
        builder: (context, state) {
          return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
            color: const Color(0xFFFF8000),
             ),
              child: ListView(
                shrinkWrap: true,
                children: state.roles != null 
                ? (state.roles?.map((Role role) {
                    return RolesItem(role);
                  }).toList()
                ) as List<Widget>
                : [],
              ),
            );
        },
      ),
    );
  }
}