part of 'subscriber_bloc.dart';

abstract class SubscriberState extends Equatable {
  const SubscriberState();

  @override
  List<Object> get props => [];
}

class SubscriberInitial extends SubscriberState {}

class SubscriberLoading extends SubscriberState {}

class SubscriberReady extends SubscriberState {
  final Subscriber subscriber;
  final String accessToken;

  final List<String> images;

  SubscriberReady({this.accessToken, this.images, this.subscriber});

  @override
  List<Object> get props => [subscriber, images];
}

class SubscriberScreenReady extends SubscriberState {
  final Subscriber subscriber;
  final List<String> images;
  final List<Review> review;
  final String accessToken;
  SubscriberScreenReady(
      {this.images, this.subscriber, this.review, this.accessToken});

  @override
  List<Object> get props => [subscriber, review, images];
}

class SubscriberError extends SubscriberState {
  final String error;

  SubscriberError({this.error});

  @override
  List<Object> get props => [error];
}
