part of 'review_bloc.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewSuccessful extends ReviewState {}

class ReviewFailure extends ReviewState {}

class ReviewLoading extends ReviewState {}
