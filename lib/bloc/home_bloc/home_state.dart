part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class LocationSet extends HomeState {
  final String location;

  LocationSet(this.location);

  @override
  List<Object> get props => [];
}

class HomeFail extends HomeState {
  final String msg;

  HomeFail(this.msg);
  @override
  List<Object> get props => [msg];
}

class HomeLoading extends HomeState {
  final String msg;

  HomeLoading(this.msg);
  @override
  List<Object> get props => [msg];
}

class CategoriesReady extends HomeState {
  final List<String> categories;

  CategoriesReady(this.categories);
  @override
  List<Object> get props => [categories];
}

class CategoryLoading extends HomeState {
  final String category;

  CategoryLoading(this.category);

  @override
  List<Object> get props => [category];
}

class CategoryLoadingFail extends HomeState {
  final String category;
  final String error;
  CategoryLoadingFail({@required this.category, @required this.error});

  @override
  List<Object> get props => [category];
}

class CategorySuccess extends HomeState {
  final List<CategorySubscriberList> categoryList;

  CategorySuccess(this.categoryList);
}

class PartCategoryReady extends HomeState {
  final List<CategorySubscriberList> categoryList;
  
  PartCategoryReady(this.categoryList);

}

class SubscribersByCategoryReady extends HomeState {
  final Map<String, List<Subscriber>> categoryMap;

  SubscribersByCategoryReady(this.categoryMap);
  @override
  List<Object> get props => [categoryMap];
}
