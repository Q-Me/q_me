import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/model/queue.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/repository/queue.dart';
import 'package:qme/repository/subscribers.dart';
import 'package:qme/utilities/logger.dart';

class SubscriberBloc extends ChangeNotifier {
  Subscriber subscriber;
  String subscriberId, queueStatus, accessToken;
  List<Queue> queuesList = [];
  List<Reception> receptionList = [];
  QueuesListRepository _queuesRepository;
  AppointmentRepository _appointmentRepository;
  SubscriberRepository _subscriberRepository;

  StreamController _queuesListController;
  StreamController _receptionListController;
  StreamController _imagesController;

  StreamSink<ApiResponse<List<Queue>>> get queuesListSink =>
      _queuesListController.sink;
  StreamSink<ApiResponse<List<Reception>>> get receptionListSink =>
      _receptionListController.sink;
  StreamSink<ApiResponse<List<String>>> get imagesSink =>
      _imagesController.sink;

  Stream<ApiResponse<List<Queue>>> get queuesListStream =>
      _queuesListController.stream;
  Stream<ApiResponse<List<Reception>>> get receptionListStream =>
      _receptionListController.stream;
  Stream<ApiResponse<List<String>>> get imageStream => _imagesController.stream;

  SubscriberBloc(this.subscriberId) {
    _queuesListController = StreamController<ApiResponse<List<Queue>>>();
    _receptionListController = StreamController<ApiResponse<List<Reception>>>();
    _imagesController = StreamController<ApiResponse<List<String>>>();

    _queuesRepository = QueuesListRepository();
    _appointmentRepository = AppointmentRepository();
    _subscriberRepository = SubscriberRepository();

    fetchSubscriberDetails();

    // TODO Get subscriber information like address and images
    // fetchQueuesList();

    // fetchReceptions and their slots
    fetchReceptions();
  }

  fetchSubscriberDetails() async {
    imagesSink.add(ApiResponse.loading('Loading images'));
    try {
      accessToken = await getAccessTokenFromStorage();
      subscriber = await _subscriberRepository.fetchSubscriberDetails(
          subscriberId: subscriberId);
      imagesSink.add(ApiResponse.completed(subscriber.displayImages));
      notifyListeners();
    } on Exception catch (e) {
      logger.e(e.toString());
      imagesSink.add(ApiResponse.error(e.toString()));
    }
  }

  fetchReceptions() async {
    receptionListSink.add(ApiResponse.loading('Fetching appointment slots'));

    try {
      final String accessToken = await getAccessTokenFromStorage();
      receptionList = await _appointmentRepository.viewReceptionsByStatus(
        subscriberId: subscriberId,
        status: ['UPCOMING', 'ACTIVE'],
        accessToken: accessToken,
      );
      // slots from start time and send and slot duration
      for (int i = 0; i < receptionList.length; i++) {
        Reception reception = receptionList[i];
        reception.createSlots();
      }
//      receptionList = filterEndedReception(receptionList);

      receptionListSink.add(ApiResponse.completed(receptionList));
    } on Exception catch (e) {
      log('Error in SubscriberBLOC:fetchExceptions:${e.toString()}');
      receptionListSink.add(ApiResponse.error(e.toString()));
    }
  }

  fetchQueuesList() async {
    queuesListSink.add(ApiResponse.loading('Fetching Queues'));
    try {
      queuesList = filterEndedQueues(
          await _queuesRepository.fetchQueueList(subscriberId, "ACTIVE"));
      final List<Queue> upcomingQueues = filterEndedQueues(
          await _queuesRepository.fetchQueueList(subscriberId, "UPCOMING"));
      queuesListSink.add(
          ApiResponse.completed(List.from(queuesList)..addAll(upcomingQueues)));
    } catch (e) {
      queuesListSink.add(ApiResponse.error(e.toString()));
      log('queue bloc:' + e.toString());
    }
  }

  dispose() {
    _queuesListController?.close();
    _receptionListController?.close();
    _imagesController?.close();
  }
}

List<Reception> filterEndedReception(List<Reception> receptions) {
  if (receptions.length == 0) {
    return receptions;
  }
  List<Reception> filteredReceptions = [];
  for (int i = 0; i < receptions.length; i++) {
    Reception reception = receptions[i];
    if (reception.endTime.isBefore(DateTime.now())) {
      continue;
    }
    filteredReceptions.add(reception);
  }
  return filteredReceptions;
}

List<Queue> filterEndedQueues(List<Queue> queues) {
  if (queues.length == 0) {
    return queues;
  }
  Queue queue;
  DateTime now = DateTime.now();
  List<Queue> finalQueueList = [];
  for (int i = 0; i < queues.length; i++) {
    queue = queues[i];

    if (!now.isAfter(queue.endDateTime)) {
      finalQueueList.add(queue);
    }
  }
  return finalQueueList;
}

void main() {
  SubscriberBloc subscriberBloc = SubscriberBloc('');
  subscriberBloc.fetchReceptions();
  for (Reception reception in subscriberBloc.receptionList) {
    print('${reception.toJson()}');
  }
}
