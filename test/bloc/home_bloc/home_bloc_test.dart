import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:qme/bloc/home_bloc/home_bloc.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/simple_bloc_observer.dart';

final accessToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjdSX3JzXzRNeiIsIm5hbWUiOiJQaXl1c2giLCJwaG9uZSI6Iis5MTk2NzM1ODI1MTciLCJpc1VzZXIiOnRydWUsImlhdCI6MTU5OTM2OTE3NywiZXhwIjoxNTk5NDU1NTc3fQ.uqLBf4NpCTgnSZ5rfEFCaC81Np5Qkc2hIetlE5MSoMw';

void main() {
  final subscriber = Subscriber.fromJson({
    "id": "QR_b9f9Qy",
    "name": "Piyush Saloon",
    "description":
        "shdgusg\r\n\r\nsdgkjgsgklbsdfkgjbjk\r\ndfjbhgdfjhgbjkfs\r\nsjzkhgjskg",
    "owner": "Mr. A",
    "email": "piyush@gmail.com",
    "phone": "+919876543210",
    "address": "Mumbai",
    "longitude": 0,
    "latitude": 0,
    "category": "Beauty & Wellness",
    "user_category": "Budget Saloon",
    "tags": "\"NULL\"",
    "profileImage": "Beauty & Wellness.png",
    "verified": 1,
    "rating": null
  });
  final categories =
      List<String>.from(["Budget Saloon", "Premium Saloon", "Safety Saloon"]);
  Bloc.observer = SimpleBlocObserver();

  blocTest(
    'Category test',
    build: () => HomeBloc(accessToken: accessToken),
    act: (bloc) {
      bloc.add(GetCategories());
    },
    expect: [
      HomeLoading('Getting categories...'),
      CategoriesReady(categories),
      PartCategoryReady(List<CategorySubscriberList>.from([
        CategorySubscriberList(
          categoryName: 'Budget Saloon',
          subscribers: [subscriber],
        )
      ])),
      PartCategoryReady(List<CategorySubscriberList>.from([
        CategorySubscriberList(
          categoryName: 'Budget Saloon',
          subscribers: [subscriber],
        ),
        CategorySubscriberList(
          categoryName: 'Premium Saloon',
          subscribers: [],
        ),
      ])),
      PartCategoryReady(List<CategorySubscriberList>.from([
        CategorySubscriberList(
          categoryName: 'Budget Saloon',
          subscribers: [subscriber],
        ),
        CategorySubscriberList(
          categoryName: 'Premium Saloon',
          subscribers: [],
        ),
      ])),
      CategorySuccess(List<CategorySubscriberList>.from([
        CategorySubscriberList(
          categoryName: 'Budget Saloon',
          subscribers: [subscriber],
        ),
        CategorySubscriberList(
          categoryName: 'Premium Saloon',
          subscribers: [],
        ),
        CategorySubscriberList(
          categoryName: 'Safety Saloon',
          subscribers: [],
        ),
      ]))
    ],
  );

  blocTest(
    'Location test',
    build: () => HomeBloc(accessToken: accessToken),
    act: (bloc) {
      bloc.add(SetLocation('Patna'));
    },
    expect: [
      HomeLoading('setting location to Patna'),
      HomeLoading('Getting categories...'),
      CategoriesReady(categories)
    ],
  );
}
