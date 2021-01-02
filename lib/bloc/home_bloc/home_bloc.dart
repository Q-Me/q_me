import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/repository/subscribers.dart';
import 'package:qme/utilities/logger.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final String accessToken;
  ValueNotifier<String> location = ValueNotifier('');
  SubscriberRepository repository;
  List<String> categories;
  List<CategorySubscriberList> categorizedSubscribers = [];

  HomeBloc({this.accessToken}) : super(HomeInitial()) {
    repository = SubscriberRepository(localAccessToken: accessToken);
    if (accessToken != null) {
      // logger.d('Access token:\n$accessToken');
    }
  }

  ValueNotifier<String> get currentLocation {
    return location;
  }

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is SetLocation) {
      if (!Hive.box('user').containsKey("location")) {
        yield HomeLoading('setting location to ${event.location}');
        Hive.box('user').put("location", event.location);
        location.value = event.location;
        categorizedSubscribers = [];
        logger.i('Location set to ${event.location}');
        this.add(GetSubscribersAllCategory());
      }
      if (Hive.box('user').containsKey("location") && Hive.box('user').get('location') != event.location) {
        yield HomeLoading('setting location to ${event.location}');
        Hive.box('user').put('location', event.location);
        location.value = event.location;
        categorizedSubscribers = [];
        logger.i('Location set to ${event.location}');
        this.add(GetSubscribersAllCategory());
      }
    } else if (event is GetCategories) {
      yield HomeLoading('Getting categories...');
      try {
        categories = await repository.subscriberCategories();
        yield CategoriesReady(categories);
        this.add(GetSubscribersAllCategory());
      } catch (e) {
        logger.e(e.toString());
        yield HomeFail(e.toString());
      }
    } else if (event is GetSubscribersAllCategory) {
      yield HomeLoading('Getting ready...');
      for (String category in categories) {
        try {
          if (location.value.length > 0) {
            final response = await repository.subscriberByLocation(
              category: category,
              location: location.value,
            );
            categorizedSubscribers.add(CategorySubscriberList(
              categoryName: category,
              subscribers: response,
            ));
          } else {
            final response = await repository.subscriberByCategory(
              category: category,
            );
            categorizedSubscribers.add(CategorySubscriberList(
              categoryName: category,
              subscribers: response,
            ));
          }
          yield PartCategoryReady(categorizedSubscribers);

          for (CategorySubscriberList value in categorizedSubscribers) {
            logger.d(value.toJson());
          }
          print('');
        } on Exception catch (e) {
          logger.e(e.toString());
          yield HomeFail(e.toString());
        }
      }
      yield CategorySuccess(categorizedSubscribers);
    }
  }
}
