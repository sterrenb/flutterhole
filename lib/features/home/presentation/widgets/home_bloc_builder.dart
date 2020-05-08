import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';

class HomeBlocBuilder extends StatelessWidget {
  const HomeBlocBuilder({
    @required this.builder,
    Key key,
  }) : super(key: key);

  final BlocWidgetBuilder<HomeState> builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      condition: (HomeState previous, HomeState next) {
        if (previous is HomeStateSuccess) return false;

        return true;
      },
      builder: builder,
    );
  }
}
