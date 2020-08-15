import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/pihole_api/blocs/list_bloc.dart';
import 'package:flutterhole/widgets/layout/notifications/snackbars.dart';

class ListBlocListener extends StatelessWidget {
  const ListBlocListener({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListBloc, ListBlocState>(
      listener: (context, state) {
        state.failureOption.fold(
          () {},
          (f) {
            showErrorSnackBar(context, '${f.message ?? f}');
          },
        );

        state.responseOption.fold(
          () {},
          (r) {
            showInfoSnackBar(context, '${r.message ?? r.success ?? r}');
          },
        );
      },
      child: child,
    );
  }
}
