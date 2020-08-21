part of 'bookingslist_bloc.dart';

abstract class BookingslistEvent extends Equatable {
  const BookingslistEvent();

  @override
  List<Object> get props => [];
}

class BookingsListRequested extends BookingslistEvent {

  BookingsListRequested();

  @override
  List<Object> get props => [];
}
