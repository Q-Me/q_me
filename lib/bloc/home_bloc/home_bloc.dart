import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:qme/model/location.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/repository/subscribers.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/utilities/location.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final String accessToken;
  ValueNotifier<LocationData> location;
  SubscriberRepository repository;
  List<String> categories;
  LinkedHashSet<CategorySubscriberList> categorizedSubscribers =
      LinkedHashSet();

  HomeBloc({this.accessToken}) : super(HomeInitial()) {
    // hydrate();
    repository = SubscriberRepository(localAccessToken: accessToken);
    if (accessToken != null) {
      // logger.d('Access token:\n$accessToken');
    }
    try {
      location = ValueNotifier(getLocationUnsafe());
    } catch (e) {
      location = ValueNotifier(null);
    }
  }

  String get currentLocationString {
    return location.value.getSimplifiedAddress;
  }

  ValueNotifier<LocationData> get currentLocation {
    return location;
  }

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is SetLocation) {
      yield* _mapSetLocationToState(event);
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
          if (location.value != null) {
            final response = await repository.subscriberByLocation(
              category: category,
              location: location.value.getApiAddress,
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

  Stream<HomeState> _mapSetLocationToState(SetLocation event) async* {
    yield HomeLoading(
        'setting location to ${event.location.getSimplifiedAddress}');
    updateStoredAddress(event.location);
    await UserRepository().updateUserLocation(event.location);
    location.value = event.location;
    categorizedSubscribers = LinkedHashSet();
    logger.i('Location set to ${event.location.getAddressComplete} \n ${event.location.latitude}, ${event.location.longitude}');
    this.add(GetSubscribersAllCategory());
  }

  // @override
  // HomeState fromJson(Map<String, dynamic> json) {
  //   return json["state"];
  // }

  // @override
  // Map<String, String> toJson(HomeState state) {
  //   if (state is HomeInitial) {
  //     return {
  //       "state": "HomeInital",
  //     };
  //   } else if (state is LocationSet) {
  //     return {
  //       "state": "LocationSet",
  //       "location": state.location,
  //     };
  //   } else if (state is HomeFail) {
  //     return {
  //       "state": "HomeFail",
  //       "msg": state.msg,
  //     };
  //   } else if (state is HomeLoading) {
  //     return {
  //       "state": "HomeFail",
  //       "msg": state.msg,
  //     };
  //   }
  // }
}
