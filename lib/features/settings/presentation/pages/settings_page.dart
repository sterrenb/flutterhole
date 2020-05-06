import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/widgets/layout/default_drawer.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        bloc: getIt<SettingsBloc>(),
        builder: (BuildContext context, SettingsState state) {
          return Scaffold(
            drawer: DefaultDrawer(),
            appBar: AppBar(
              title: state.maybeWhen<Widget>(
                success: (all, active) {
                  return Text('${active?.title}');
                },
                orElse: () => Text('FlutterHole'),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    getIt<SettingsBloc>().add(SettingsEventCreate());
                  },
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    getIt<SettingsBloc>().add(SettingsEventInit());
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    getIt<SettingsBloc>().add(SettingsEventReset());
                  },
                ),
              ],
            ),
            body: state.maybeWhen<Widget>(
              success: (all, active) {
                return ListView.builder(
                    itemCount: all.length,
                    itemBuilder: (context, index) {
                      final settings = all.elementAt(index);
                      return OpenContainer(
                        tappable: false,
                        openElevation: 0,
                        closedElevation: 0,
                        closedBuilder:
                            (BuildContext context, VoidCallback openContainer) {
                          return ListTile(
                            title: Text('${settings.title}'),
                            trailing: Visibility(
                              visible: settings == active,
                              child: Icon(Icons.check),
                            ),
                            onTap: openContainer,
                          );
                        },
                        openBuilder: (BuildContext context,
                            VoidCallback closeContainer) {
                          return Scaffold();
                        },
                      );
                    });
              },
              orElse: () {
                return Center(
                  child: Text('hello'),
                );
              },
            ),
          );
        });
  }
}
