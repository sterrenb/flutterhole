import 'package:bloc/bloc.dart';

class _SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

/// Print bloc transitions to stdout.
void enableBlocDelegate() =>
    BlocSupervisor.delegate = _SimpleBlocDelegate();
