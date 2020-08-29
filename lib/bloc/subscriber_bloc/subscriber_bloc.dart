import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/model/review.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/subscribers.dart';
import 'package:qme/utilities/logger.dart';

part 'subscriber_event.dart';
part 'subscriber_state.dart';

List<String> _images = [];
List<Review> _review = [];
SubscriberBloc _bloc = SubscriberBloc();

class SubscriberBloc extends Bloc<SubscriberEvent, SubscriberState> {
  SubscriberBloc() : super(SubscriberLoading());

  @override
  Stream<SubscriberState> mapEventToState(
    SubscriberEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is ProfileInitialEvent) {
      yield* _mapInitialEventToState(event.subscriber.id);
    }
    if (event is FetchReviewEvent) {
      yield* _mapFetchReviewEventToState(event.subscriber.id);
    }
  }
}

Stream<SubscriberState> _mapInitialEventToState(subscriberId) async* {
  yield SubscriberLoading();
  Subscriber subscriber;
  String accessToken;
  SubscriberRepository _subscriberRepository = SubscriberRepository();
  // imagesSink.add(ApiResponse.loading('Loading images'));
  try {
    accessToken = await getAccessTokenFromStorage();
    subscriber = await _subscriberRepository.fetchSubscriberDetails(
        subscriberId: subscriberId);
    // _review = await _subscriberRepository.fetchSubscriberReviews(
    //     subscriberId: subscriberId);
    _images = subscriber.displayImages;
    print('loaded');

    yield SubscriberReady(subscriber: subscriber, images: _images);

    // imagesSink.add(ApiResponse.completed(subscriber.displayImages));
  } on Exception catch (e) {
    logger.e(e.toString());
    print('error');

    yield SubscriberError(error: e.toString());
    // imagesSink.add(ApiResponse.error(e.toString()));
  }
}

Stream<SubscriberState> _mapFetchReviewEventToState(subscriberId) async* {
  yield SubscriberLoading();
  Subscriber subscriber;
  String accessToken;
  SubscriberRepository _subscriberRepository = SubscriberRepository();
  try {
    accessToken = await getAccessTokenFromStorage();

    _review = await _subscriberRepository.fetchSubscriberReviews(
        subscriberId: subscriberId);
    print('loaded');

    yield SubscriberScreenReady(
        subscriber: subscriber, images: _images, review: _review);

    // imagesSink.add(ApiResponse.completed(subscriber.displayImages));
  } on Exception catch (e) {
    logger.e(e.toString());
    print('error');

    yield SubscriberError(error: e.toString());
    // imagesSink.add(ApiResponse.error(e.toString()));
  }
}
