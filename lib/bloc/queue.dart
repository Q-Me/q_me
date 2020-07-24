import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/model/queue.dart';
import 'package:qme/repository/queue.dart';
import 'package:qme/repository/token.dart';

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

  @override
  dispose() {
    _queueController?.close();
    _tokenController?.close();
    _msgController?.close();
    super.dispose();
  }
}
