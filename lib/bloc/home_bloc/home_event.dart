part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class SetLocation extends HomeEvent {
  final String location;

  SetLocation(this.location);
}

class GetCategories extends HomeEvent {}

class GetSubscribersAllCategory extends HomeEvent {}

class GetSubscribersByCategory extends HomeEvent {
  final String category;

  GetSubscribersByCategory(this.category);
}
