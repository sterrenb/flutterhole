import 'package:bloc/bloc.dart';

/// Prints transition info for [Bloc]s under its [BlocSupervisor].
class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
