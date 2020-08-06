import 'package:bloc/bloc.dart';
import 'package:qme/utilities/logger.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    logger.d('onEvent $event');
    super.onEvent(bloc, event);
  }

  @override
  onTransition(Bloc bloc, Transition transition) {
    logger.d('onTransition $transition');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Cubit bloc, Object error, StackTrace stackTrace) {
    logger.d('onError $error');
    super.onError(bloc, error, stackTrace);
  }
}
