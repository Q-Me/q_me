import '../repository/queue.dart';
import 'dart:async';
import '../api/base_helper.dart';
import '../model/queue.dart';

class QueuesBloc {
  QueuesRepository _queuesRepository;

  StreamController _queuesListController;

  StreamSink<ApiResponse<List<Queue>>> get queuesListSink =>
      _queuesListController.sink;

  Stream<ApiResponse<List<Queue>>> get queuesListStream =>
      _queuesListController.stream;
  String subscriberId;
  QueuesBloc(String subscriberId, String status) {
    subscriberId = subscriberId;
    _queuesListController = StreamController<ApiResponse<List<Queue>>>();
    _queuesRepository = QueuesRepository();
    fetchQueuesList(status);
  }

  fetchQueuesList(String status) async {
    queuesListSink.add(ApiResponse.loading('Fetching $status Queues'));
    try {
      List<Queue> queues =
          await _queuesRepository.fetchQueueList(subscriberId, status);
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
