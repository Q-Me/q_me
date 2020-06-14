import 'package:flutter/cupertino.dart';
import 'package:qme/model/user.dart';

import '../repository/subscribers.dart';
import '../api/base_helper.dart';
import '../model/subscriber.dart';
import 'dart:async';
import 'dart:developer';

class SubscribersBloc extends ChangeNotifier {
  SubscribersRepository _subscribersRepository;
  String _accessToken;
  String _category;

  Future<void> setCategory(String category) async {
    _category = category;
    await getSubscriberByCategory(category: _category);
  }

  List<Subscriber> subscriberList;

  StreamController _subscribersListController;

  StreamSink<ApiResponse<List<Subscriber>>> get subscribersListSink =>
      _subscribersListController.sink;

  Stream<ApiResponse<List<Subscriber>>> get subscribersListStream =>
      _subscribersListController.stream;

  SubscribersBloc() {
    _subscribersListController =
        StreamController<ApiResponse<List<Subscriber>>>();
    _subscribersRepository = SubscribersRepository();
    fetchSubscribersList();
  }

  fetchSubscribersList() async {
    subscribersListSink
        .add(ApiResponse.loading('Fetching Popular Subscribers'));
    try {
      List<Subscriber> subscribers =
          await _subscribersRepository.fetchSubscriberList();
      subscriberList = subscribers;
      subscribersListSink.add(ApiResponse.completed(subscribers));
    } catch (e) {
      subscribersListSink.add(ApiResponse.error(e.toString()));
      log('Error in Subscriber BLoC:fetchSubscribersList:' + e.toString());
    }
  }

  getSubscriberByCategory({@required String category, String location}) async {
    subscribersListSink.add(ApiResponse.loading('Fetching $category\'s'));
    _accessToken = await getAccessTokenFromStorage();

    try {
      List<Subscriber> categorySubscribers =
          await _subscribersRepository.subscriberByCategory(
        category: category,
        accessToken: _accessToken,
      );
      subscriberList = categorySubscribers;
      subscribersListSink.add(ApiResponse.completed(subscriberList));
    } catch (e) {
      subscribersListSink.add(ApiResponse.error(e.toString()));
      log('Error in Subscriber BLoC:fetchSubscribersList:' + e.toString());
    }
  }

  dispose() {
    _subscribersListController?.close();
  }
}

class SingleSubscriberBloc {
  SingleSubscriberRepository _subscriberRepository;

  StreamController _subscriberController;

  StreamSink<ApiResponse<Subscriber>> get subscriberSink =>
      _subscriberController.sink;

  Stream<ApiResponse<Subscriber>> get subscribersListStream =>
      _subscriberController.stream;

  SingleSubscriberBloc(String subscriberId) {
    _subscriberController = StreamController<ApiResponse<Subscriber>>();
    _subscriberRepository = SingleSubscriberRepository();
    fetchSubscriber(subscriberId);
  }

  fetchSubscriber(String subscriberId) async {
    subscriberSink.add(ApiResponse.loading('Fetching subscriber details'));
    try {
      Subscriber subscriber =
          await _subscriberRepository.fetchSubscriber(subscriberId);
      subscriberSink.add(ApiResponse.completed(subscriber));
    } catch (e) {
      subscriberSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _subscriberController?.close();
  }
}
