import 'dart:collection';
import 'dart:developer';

import '../api/base_helper.dart';
import '../api/endpoints.dart';
import '../model/queue.dart';
import '../model/user.dart';

class QueuesListRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<Queue>> fetchQueueList(String subscriberId, String status) async {
    final UserData userData = await getUserDataFromStorage();
    log('User token is ${userData.accessToken}\nSubscriber ID is $subscriberId\nStatus is $status');

    final response = await _helper.post(
      getAllSubscriberQueues,
      headers: {'Authorization': 'Bearer ${userData.accessToken}'},
      req: {'subscriber_id': subscriberId, 'status': status},
    );

    /*List<Queue> queues = [];
    Queues.fromJson(response).queue.forEach((queue) async {
      Queue queueObj = await fetchQueue(queue.queueId);
      queues.add(queueObj);
    });*/

    return Queues.fromJson(response).queue;
  }
}

class QueueRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<Queue> fetchQueue(String queueId) async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(
      getQueue,
      headers: {'Authorization': 'Bearer ${userData.accessToken}'},
      req: {'queue_id': queueId},
    );
//    log('Queue Repo($queueId): $response');
    return Queue.fromJson(response);
  }
}
