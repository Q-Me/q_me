part of 'subscriber_bloc.dart';

abstract class SubscriberState extends Equatable {
  const SubscriberState();

  @override
  List<Object> get props => [];
}

class SubscriberInitial extends SubscriberState {}

class SubscriberLoading extends SubscriberState {}

class SubscriberReady extends SubscriberState {}

class SubscriberScreenReady extends SubscriberState {}

class SubscriberError extends SubscriberState {}
