part of 'cancel_bloc.dart';

abstract class CancelEvent extends Equatable {
  const CancelEvent();
}

class CancelRequestedEvent extends CancelEvent {
  final String counterId;
  final String accessToken;

  CancelRequestedEvent(this.counterId, this.accessToken) : assert(accessToken != null && counterId != null);

  @override
  List<Object> get props => [counterId, accessToken];
}
