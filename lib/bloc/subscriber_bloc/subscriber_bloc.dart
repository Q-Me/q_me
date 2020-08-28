import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:qme/model/subscriber.dart';

part 'subscriber_event.dart';
part 'subscriber_state.dart';

class SubscriberBloc extends Bloc<SubscriberEvent, SubscriberState> {
  SubscriberBloc() : super(SubscriberInitial());

  @override
  Stream<SubscriberState> mapEventToState(
    SubscriberEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is ProfileInitialEvent) {
      yield* _mapInitialEventToState();
    }
  }
}

Stream<SubscriberState> _mapInitialEventToState() async* {
  yield SubscriberLoading();
}
