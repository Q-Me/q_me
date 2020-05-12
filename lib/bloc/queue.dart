import '../repository/queue.dart';
import '../repository/token.dart';
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

  StreamSink<ApiResponse<Queue>> get queueSink => _queueController.sink;

  Stream<ApiResponse<Queue>> get queueStream => _queueController.stream;
  QueueBloc(this.queueId) {
    _queueController = StreamController<ApiResponse<Queue>>();
    _queueRepository = QueueRepository();
    fetchQueueData();
  }

  fetchQueueData() async {
    queueSink.add(ApiResponse.loading('Fetching Queue details'));
    try {
      Queue queues = await _queueRepository.fetchQueue(queueId);
      queueSink.add(ApiResponse.completed(queues));
    } catch (e) {
      queueSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _queueController?.close();
  }
}

class JoinQueueBloc {
  String queueId;
  TokenRepository _tokenRepository;

  StreamController _tokenController;

  StreamSink<ApiResponse<Map>> get joinQueueSink => _tokenController.sink;

  Stream<ApiResponse<Map>> get tokenStream => _tokenController.stream;
  JoinQueueBloc(this.queueId) {
    _tokenController = StreamController<ApiResponse<Queue>>();
    _tokenRepository = TokenRepository();
    fetchQueueData();
  }

  fetchQueueData() async {
    joinQueueSink.add(ApiResponse.loading('Fetching Queue details'));
    try {
      Map token = await _tokenRepository.joinQueue(queueId);
      joinQueueSink.add(ApiResponse.completed(token));
    } catch (e) {
      joinQueueSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _tokenController?.close();
  }
}
