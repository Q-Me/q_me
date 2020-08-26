import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:qme/utilities/logger.dart';

import '../api/base_helper.dart';
import '../model/subscriber.dart';
import '../model/user.dart';
import '../repository/subscribers.dart';

class SubscribersBloc extends ChangeNotifier {
  SubscriberRepository _subscribersRepository;
  String _accessToken;
  String _category;

  Future<void> setCategory(String category) async {
    _category = category;
    await getSubscriberByCategory(category: _category);
  }

  List<Subscriber> subscriberList = [];

  StreamController _subscribersListController;

  StreamSink<ApiResponse<List<Subscriber>>> get subscribersListSink =>
      _subscribersListController.sink;

  Stream<ApiResponse<List<Subscriber>>> get subscribersListStream =>
      _subscribersListController.stream;

  String get accessToken => _accessToken;

  SubscribersBloc() {
    _subscribersListController =
        StreamController<ApiResponse<List<Subscriber>>>();
    _subscribersRepository = SubscriberRepository();
    fetchSubscribersList();
  }

  fetchSubscribersList() async {
    subscribersListSink
        .add(ApiResponse.loading('Fetching Popular Subscribers'));
    try {
      List<Subscriber> subscribers =
          await _subscribersRepository.fetchSubscriberList();
      _accessToken = await getAccessTokenFromStorage();

      subscriberList = subscribers;
      subscribersListSink.add(ApiResponse.completed(subscribers));
    } catch (e) {
      subscribersListSink.add(ApiResponse.error(e.toString()));
      logger.e('Error in Subscriber BLoC:fetchSubscribersList:' + e.toString());
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
      logger.e('Error in Subscriber BLoC:fetchSubscribersList:' + e.toString());
    }
  }

  dispose() {
    super.dispose();
    _subscribersListController?.close();
  }
}
