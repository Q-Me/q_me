import 'dart:collection';

import 'package:qme/api/base_helper.dart';
import 'package:qme/api/endpoints.dart';
import 'package:qme/model/queue.dart';
import 'package:qme/model/user.dart';

class QueuesListRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<Queue>> fetchQueueList(String subscriberId, String status) async {
    final String accessToken = await getAccessTokenFromStorage();
//    log('User token is ${accessToken}\nSubscriber ID is $subscriberId\nStatus is $status');

    final response = await _helper.post(
      getAllSubscriberQueues,
      headers: {'Authorization': 'Bearer $accessToken'},
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
    final String accessToken = await getAccessTokenFromStorage();
    final response = await _helper.post(
      getQueue,
      headers: {'Authorization': 'Bearer $accessToken'},
      req: {'queue_id': queueId},
    );
//    log('Queue Repo($queueId): $response');
    return Queue.fromJson(response);
  }
}
