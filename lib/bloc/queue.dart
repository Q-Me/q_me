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

class QueueBloc {
  String queueId;
  QueueRepository _queueRepository;

  StreamController _queueController;

  StreamSink<ApiResponse<Queue>> get queuesListSink => _queueController.sink;

  Stream<ApiResponse<Queue>> get queuesListStream => _queueController.stream;
  QueueBloc(this.queueId) {
    _queueController = StreamController<ApiResponse<Queue>>();
    _queueRepository = QueueRepository();
    fetchQueueData();
  }

  fetchQueueData() async {
    queuesListSink.add(ApiResponse.loading('Fetching Queue details'));
    try {
      Queue queues = await _queueRepository.fetchQueue(queueId);
      queuesListSink.add(ApiResponse.completed(queues));
    } catch (e) {
      queuesListSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _queueController?.close();
  }
}
