import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:qme/model/token.dart';

import '../repository/queue.dart';
import '../repository/token.dart';
import 'dart:async';
import 'dart:developer';
import '../api/base_helper.dart';
import '../model/queue.dart';

class QueuesBloc {
  String subscriberId, queueStatus;
  List<Queue> queuesList;
  QueuesListRepository _queuesRepository;

  StreamController _queuesListController;

  StreamSink<ApiResponse<List<Queue>>> get queuesListSink =>
      _queuesListController.sink;

  Stream<ApiResponse<List<Queue>>> get queuesListStream =>
      _queuesListController.stream;
  QueuesBloc(this.subscriberId) {
    _queuesListController = StreamController<ApiResponse<List<Queue>>>();
    _queuesRepository = QueuesListRepository();
    fetchQueuesList();
  }

  fetchQueuesList() async {
    queuesListSink.add(ApiResponse.loading('Fetching Queues'));
    try {
      queuesList =
          await _queuesRepository.fetchQueueList(subscriberId, "ACTIVE");
      final List<Queue> upcomingQueues =
          await _queuesRepository.fetchQueueList(subscriberId, "UPCOMING");
      queuesListSink.add(
          ApiResponse.completed(List.from(queuesList)..addAll(upcomingQueues)));
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
  Queue queue;

  QueueRepository _queueRepository;
  TokenRepository _tokenRepository;

  StreamController _queueController;
  StreamController _tokenController;
  StreamController _msgController;

  StreamSink<ApiResponse<Queue>> get queueSink => _queueController.sink;
  StreamSink<ApiResponse<String>> get msgSink => _msgController.sink;

  Stream<ApiResponse<Queue>> get queueStream => _queueController.stream;
  Stream<ApiResponse<String>> get msgStream => _msgController.stream;

  QueueBloc(this.queueId) {
    _queueController = StreamController<ApiResponse<Queue>>();
    _msgController = StreamController<ApiResponse<String>>();

    _queueRepository = QueueRepository();
    fetchQueueData();
  }

  fetchQueueData() async {
    queueSink.add(ApiResponse.loading('Fetching Queue details'));
    msgSink.add(ApiResponse.loading('Fetching Queue details'));
    msgSink.add(ApiResponse.loading('Fetching token details'));
    try {
      Queue _queue = await _queueRepository.fetchQueue(queueId);
      if (_queue.token != null && _queue.token.tokenNo != -1) {
        msgSink.add(ApiResponse.completed('User already  in queue.'));
      } else {
        msgSink.add(ApiResponse.completed('User not in queue.'));
      }
      queue = _queue;
      queueSink.add(ApiResponse.completed(_queue));
      log('1. Added a queue to stream');
    } catch (e) {
      queueSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  joinQueue() async {
    _tokenRepository = TokenRepository();
    msgSink.add(ApiResponse.loading('Fetching token details'));
    try {
      Map response = await _tokenRepository.joinQueue(queueId);
      msgSink.add(ApiResponse.completed(response['msg']));
      // 'User added to queue successfully.'
      queue.token = response['token'];
    } catch (e) {
      msgSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  cancelToken() async {
    msgSink.add(ApiResponse.loading('Cancelling token'));
    _tokenRepository = TokenRepository();
    try {
      log('Initialising cancel token request');
      Map response = await _tokenRepository.cancelToken(queueId);
      msgSink.add(ApiResponse.completed(response['msg']));
      log('Cancel token successful');
      queue.token = null;
    } catch (e) {
      msgSink.add(ApiResponse.error(e.toString()));
      log(e.toString());
    }
  }

  dispose() {
    _queueController?.close();
    _tokenController?.close();
    _msgController?.close();
  }
}
