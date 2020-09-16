import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:qme/repository/subscribers.dart';
import 'package:qme/services/analytics.dart';
import 'package:qme/utilities/logger.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc() : super(ReviewInitial());

  @override
  Stream<ReviewState> mapEventToState(
    ReviewEvent event,
  ) async* {
    if (event is ReviewPostRequested) {
      yield* _mapReviewPostRequestedEventToState(event);
    }
  }

  Stream<ReviewState> _mapReviewPostRequestedEventToState(
      ReviewPostRequested event) async* {
    yield ReviewLoading();
    try {
      final response = await SubscriberRepository().rateSubscriber(
        counterId: event.counterId,
        subscriberId: event.subscriberId,
        review: event.review,
        rating: event.rating,
      );
      logger.d(response.toString());
      AnalyticsService().getAnalyticsObserver().analytics.logEvent(
            name: "Added review",
          );
      yield ReviewSuccessful();
    } catch (e) {
      logger.e(e.toString());
      yield ReviewFailure();
    }
  }
}
