import '../repository/queue.dart';
import 'dart:async';
import '../api/base_helper.dart';
import '../model/queue.dart';

class QueuesBloc {
  String subscriberId, queueStatus;
  QueuesListRepository _queuesRepository;

  StreamController _queuesListController;

  StreamSink<ApiResponse<List<Queue>>> get queuesListSink =>
      _queuesListController.sink;

  Stream<ApiResponse<List<Queue>>> get queuesListStream =>
      _queuesListController.stream;
  QueuesBloc(this.subscriberId, this.queueStatus) {
    _queuesListController = StreamController<ApiResponse<List<Queue>>>();
    _queuesRepository = QueuesListRepository();
    fetchQueuesList();
  }

  fetchQueuesList() async {
    queuesListSink.add(ApiResponse.loading('Fetching $queueStatus Queues'));
    try {
      List<Queue> queues =
          await _queuesRepository.fetchQueueList(subscriberId, queueStatus);
      queuesListSink.add(ApiResponse.completed(queues));
    } catch (e) {
      queuesListSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _queuesListController?.close();
  }
}
