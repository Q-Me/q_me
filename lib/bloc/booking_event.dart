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

  BookingRequested(this.subscriberId, this.note, this.counterId, this.startTime,
      this.endTime)
      : assert(counterId != null &&
            subscriberId != null &&
            startTime != null &&
            endTime != null );

  @override
  List<Object> get props =>
      [subscriberId, note, counterId, startTime, endTime];
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

// class CancelRequested extends BookingEvent {
//   final String counterId;
//   final String accessToken;

//   CancelRequested(this.counterId, this.accessToken)
//       : assert(accessToken != null && counterId != null);

//   @override
//   List<Object> get props => [counterId, accessToken];
// }
