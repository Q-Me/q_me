import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/repository/subscribers.dart';
import 'package:qme/utilities/logger.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final String accessToken;
  String location;
  SubscriberRepository repository;
  List<String> categories;
  Map<String, List<Subscriber>> categorizedSubscribers;

  HomeBloc({this.accessToken}) : super(HomeInitial()) {
    repository = SubscriberRepository();
  }

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is SetLocation) {
      location = event.location;
      this.add(GetCategories());
    } else if (event is GetCategories) {
      try {
        categories = await repository.subscriberCategories();
        yield CategoriesReady(categories);
      } catch (e) {
        logger.e(e.toString());
        yield HomeFail(e.toString());
      }
    } else if (event is GetSubscribersByCategory){
      
    }
  }
}
