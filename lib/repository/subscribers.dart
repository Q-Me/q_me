import '../model/subscriber.dart';
import '../model/user.dart';
import '../api/base_helper.dart';
import '../api/endpoints.dart';

class SubscribersRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<Subscriber>> fetchSubscriberList() async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(getAllSubscribers,
        headers: {'Authorization': 'Bearer ${userData.accessToken}'});
    return Subscribers.fromJson(response).list;
  }
}

class SingleSubscriberRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<Subscriber> fetchSubscriber(String subscriberId) async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(getSubscriberFromId,
        headers: {'Authorization': 'Bearer ${userData.accessToken}'},
        req: {'subscriber_id': subscriberId});
    return Subscriber.fromJson(response);
  }
}
