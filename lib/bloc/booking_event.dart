part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
}

class BookingRequested extends BookingEvent {
  final String subscriberId;
  final String note;
  final String counterId;
  final DateTime startTime;
  final DateTime endTime;
  final String accessToken;

  BookingRequested(this.subscriberId, this.note, this.counterId, this.startTime,
      this.endTime, this.accessToken)
      : assert(counterId != null &&
            subscriberId != null &&
            startTime != null &&
            endTime != null &&
            accessToken != null);

  @override
  List<Object> get props =>
      [subscriberId, note, counterId, startTime, endTime, accessToken];
}

class BookingRefreshRequested extends BookingEvent {
  @override
  List<Object> get props => [];
}

class BookingExists extends BookingEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}
