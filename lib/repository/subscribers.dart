import '../repository/user.dart';
import 'dart:async';
import 'dart:developer';

import '../model/subscriber.dart';
import '../model/user.dart';
import '../api/base_helper.dart';
import '../api/endpoints.dart';

class SubscribersRepository {
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
//    log("${Subscribers.fromJson(response).list[0].toJson()}");
    return Subscribers.fromJson(response).list;
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
}

class SingleSubscriberRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<Subscriber> fetchSubscriber(String subscriberId) async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(kGetSubscriberFromId,
        headers: {'Authorization': 'Bearer ${userData.accessToken}'},
        req: {'subscriber_id': subscriberId});
    return Subscriber.fromJson(response);
  }
}
