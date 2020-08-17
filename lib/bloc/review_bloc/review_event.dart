part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
}

class ReviewPostRequested extends ReviewEvent {
  final String counterId;
  final String subscriberId;
  final String rating;
  final String review;

  ReviewPostRequested(
      {@required this.counterId,
      @required this.subscriberId,
      @required this.rating,
      @required this.review});

  @override
  List<Object> get props => [counterId, subscriberId, rating, review];
}
