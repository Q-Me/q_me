import 'package:flutter/cupertino.dart';
import 'package:qme/model/token.dart';

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

class QueueBloc with ChangeNotifier {
  String queueId;
  QueueRepository _queueRepository;
  TokenRepository _tokenRepository;

  StreamController _queueController;
  StreamController _tokenController;
  StreamController _msgController;

  StreamSink<ApiResponse<Queue>> get queueSink => _queueController.sink;
  StreamSink<ApiResponse<QueueToken>> get tokenSink => _tokenController.sink;
  StreamSink<ApiResponse<String>> get msgSink => _msgController.sink;

  Stream<ApiResponse<Queue>> get queueStream => _queueController.stream;
  Stream<ApiResponse<Map>> get tokenStream => _queueController.stream;
  Stream<ApiResponse<String>> get msgStream => _queueController.stream;

  QueueBloc(this.queueId) {
    _queueController = StreamController<ApiResponse<Queue>>();
    _tokenController = StreamController<ApiResponse<QueueToken>>();
    _msgController = StreamController<ApiResponse<String>>();

    _queueRepository = QueueRepository();
    fetchQueueData();
  }

  fetchQueueData() async {
    queueSink.add(ApiResponse.loading('Fetching Queue details'));
    msgSink.add(ApiResponse.loading('Fetching Queue details'));
    try {
      Queue queue = await _queueRepository.fetchQueue(queueId);
      if (queue.token.tokenNo != -1) {
        tokenSink.add(ApiResponse.completed(queue.token));
        msgSink.add(ApiResponse.completed('User already  in queue.'));
      }
      queueSink.add(ApiResponse.completed(queue));
    } catch (e) {
      queueSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  joinQueue() async {
    msgSink.add(ApiResponse.loading('Fetching token details'));
    try {
      Map token = await _tokenRepository.joinQueue(queueId);
      msgSink.add(ApiResponse.completed(token['msg']));
      if (token['msg'] == 'User added to queue successfully.')
        tokenSink
            .add(ApiResponse.completed(QueueToken(tokenNo: token['token_no'])));
    } catch (e) {
      msgSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  cancelToken() async {
    msgSink.add(ApiResponse.loading('Cancelling token'));
    try {
      Map response = await _tokenRepository.cancelToken(queueId);
      msgSink.add(ApiResponse.completed(response['msg']));
    } catch (e) {
      msgSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _queueController?.close();
    _tokenController?.close();
    _msgController?.close();
  }
}
