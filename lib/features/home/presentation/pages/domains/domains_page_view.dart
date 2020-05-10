import 'package:flutter/material.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/home/presentation/widgets/home_bloc_builder.dart';

class DomainsPageView extends StatelessWidget {
  const DomainsPageView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeBlocBuilder(
      builder: (BuildContext context, HomeState state) {
        return Container();
      },
    );
  }
}
