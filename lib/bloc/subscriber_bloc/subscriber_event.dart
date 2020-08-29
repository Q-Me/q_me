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
  List<Object> get props => [subscriber];
}

class FetchReviewEvent extends SubscriberEvent {
  final Subscriber subscriber;

  FetchReviewEvent({this.subscriber});

  @override
  List<Object> get props => [subscriber];
}
