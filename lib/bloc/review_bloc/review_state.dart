part of 'review_bloc.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewSuccessful extends ReviewState {
  final String counterId;
  final String subscriberId;
  final String rating;
  final String review;

  ReviewSuccessful({@required this.counterId,
      @required this.subscriberId,
      @required this.rating,
      @required this.review});

  @override
  List<Object> get props => [counterId, subscriberId, rating, review];
}

class ReviewFailure extends ReviewState {}

class ReviewLoading extends ReviewState {}
