part of 'subscriber_bloc.dart';

abstract class SubscriberEvent extends Equatable {
  const SubscriberEvent();

  @override
  List<Object> get props => [];
}

class ProfileInitialEvent extends SubscriberEvent {
  final Subscriber subscriber;

  ProfileInitialEvent({this.subscriber});

  @override
  // TODO: implement props
  List<Object> get props => [subscriber];
}
