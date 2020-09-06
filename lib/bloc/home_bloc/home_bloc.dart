import 'dart:async';
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
  String location = 'Patna';
  SubscriberRepository repository;
  List<String> categories;
  List<CategorySubscriberList> categorizedSubscribers;

  HomeBloc({this.accessToken}) : super(HomeInitial()) {
    repository = SubscriberRepository(localAccessToken: accessToken);
    if (accessToken != null) {
      // logger.d('Access token:\n$accessToken');
    }
  }

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is SetLocation) {
      yield HomeLoading('setting location to ${event.location}');
      location = event.location;
      this.add(GetCategories());
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
      yield HomeLoading('Getting ready..');
      for (String category in categories) {
        try {
          final response = await repository.subscriberByCategory(
            category: category,
            location: location,
          );
          categorizedSubscribers.add(CategorySubscriberList(
            categoryName: category,
            subscribers: response,
          ));
          yield PartCategoryReady(categorizedSubscribers);

          for (CategorySubscriberList value in categorizedSubscribers) {
            print(value.toJson());
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
