part of 'bookingslist_bloc.dart';

abstract class BookingslistEvent extends Equatable {
  const BookingslistEvent();

  @override
  List<Object> get props => [];
}

class BookingsListRequested extends BookingslistEvent {
  final List<String> statusRequired;
  BookingsListRequested({this.statusRequired});

  @override
  List<Object> get props => [statusRequired];
}

class CancelRequested extends BookingslistEvent {
  final String counterId;
  final String accessToken;

  CancelRequested(this.counterId, this.accessToken)
      : assert(accessToken != null && counterId != null);

  @override
  List<Object> get props => [counterId, accessToken];
}