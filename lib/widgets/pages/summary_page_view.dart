import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/blocs/home_bloc.dart';

class SummaryPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
        builder: (BuildContext context, HomeState state) {
      return Center(
        child: Text('$state'),
      );
    });
  }
}
