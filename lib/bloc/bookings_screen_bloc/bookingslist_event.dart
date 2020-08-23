part of 'bookingslist_bloc.dart';

abstract class BookingslistEvent extends Equatable {
  const BookingslistEvent();

  @override
  List<Object> get props => [];
}

class BookingsListRequested extends BookingslistEvent {
  final String statusRequired;
  BookingsListRequested({this.statusRequired});

  @override
  List<Object> get props => [statusRequired];
}
