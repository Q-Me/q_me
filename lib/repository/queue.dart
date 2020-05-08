import '../model/queue.dart';
import '../model/user.dart';
import '../api/base_helper.dart';
import '../api/endpoints.dart';

class QueuesRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<Queue>> fetchQueueList(String subscriberId, String status) async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(getAllSubscriberQueues,
        headers: {'Authorization': 'Bearer ${userData.accessToken}'},
        req: {'subscriber_id': subscriberId, 'status': status});
    return Queues.fromJson(response).queue;
  }
}

void main() async {
  QueuesRepository queuesRepository = QueuesRepository();
  List<Queue> queues =
      await queuesRepository.fetchQueueList('_fcGtvm7g', 'UPCOMING');
  print(queues[0].queueId);
}
