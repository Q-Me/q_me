import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:qme/utilities/logger.dart';

import '../api/base_helper.dart';
import '../api/endpoints.dart';
import '../model/subscriber.dart';
import '../model/user.dart';
import '../repository/user.dart';

class SubscriberRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<Subscriber>> fetchSubscriberList({String accessToken}) async {
    /*Get all subscribers list*/
    UserData userData = await getUserDataFromStorage();
    dynamic response = await _helper.post(kGetAllSubscribers,
        headers: {'Authorization': 'Bearer ${userData.accessToken}'});
    if (response['error'] == 'Invalid access token') {
      final userRepo = UserRepository();
      String accessToken = await userRepo.accessTokenFromApi();
      userData = await getUserDataFromStorage();
      response = await _helper.post(kGetAllSubscribers,
          headers: {'Authorization': 'Bearer $accessToken'});
    }
    logger.d('fetchSubscriberList repository: ${response.toString()}');
//    log("${Subscribers.fromJson(response).list[0].toJson()}");
    return Subscribers.fromJson(response).list;
  }

  Future<Subscriber> fetchSubscriberDetails(
      {@required String subscriberId}) async {
    final String accessToken = await getAccessTokenFromStorage();
    final response = await _helper.post(
      '/user/getsubscriber',
      req: {"subscriber_id": subscriberId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return Subscriber.fromJson(response);
  }

  Future<List<Subscriber>> subscriberListByLocation({
    String location,
    String category,
    String accessToken,
  }) async {
    final response = await _helper.post(
      kSubscriberByLocation,
      req: {
        'location': location,
        'category': category,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return Subscribers.fromJson(response).list;
  }

  Future<List<Subscriber>> subscriberByCategory({
    String location,
    String category,
    String accessToken,
  }) async {
    final response = await _helper.post(
      kSubscriberByCategory,
      req: {
        'location': location,
        'category': category,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return Subscribers.fromJson(response).list;
  }

  Future<String> rateSubscriber({
    String counterId,
    String subscriberId,
    String review,
    String rating,
  }) async {
    final String accessToken = await getAccessTokenFromStorage();
    final response = await _helper.post(
      reviewUrl,
      req: {
        "counter_id": counterId,
        "subscriber_id": subscriberId,
        "review": review, //OPTIONAL
        "rating": rating,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }
}
