import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:qme/api/base_helper.dart';
import 'package:qme/model/queue.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/repository/queue.dart';

class BookingBloc {
  String subscriberId, queueStatus;
  List<Queue> queuesList = [];
  List<Reception> receptionList = [];
  QueuesListRepository _queuesRepository;
  AppointmentRepository _appointmentRepository;

  StreamController _queuesListController;
  StreamController _receptionListController;

  StreamSink<ApiResponse<List<Queue>>> get queuesListSink =>
      _queuesListController.sink;
  StreamSink<ApiResponse<List<Reception>>> get receptionListSink =>
      _receptionListController.sink;

  Stream<ApiResponse<List<Queue>>> get queuesListStream =>
      _queuesListController.stream;
  Stream<ApiResponse<List<Queue>>> get receptionListStream =>
      _receptionListController.stream;

  BookingBloc(this.subscriberId) {
    _queuesListController = StreamController<ApiResponse<List<Queue>>>();
    _receptionListController = StreamController<ApiResponse<List<Reception>>>();

    _queuesRepository = QueuesListRepository();
    _appointmentRepository = AppointmentRepository();

    fetchQueuesList();
    // TODO fetchReceptions and their slots
  }
  fetchReceptions() async {
    final response = jsonDecode('''{
    "counters": [
        {
            "id": "FyKQeYVM8",
            "subscriber_id": "17dY6K8Hb",
            "starttime": "2020-06-28T20:00:00.000Z",
            "endtime": "2020-06-28T21:00:00.000Z",
            "slot": 15,
            "cust_per_slot": 1,
            "status": "UPCOMING"
        },
        {
            "id": "pgXN_rw-0",
            "subscriber_id": "17dY6K8Hb",
            "starttime": "2020-06-28T18:00:00.000Z",
            "endtime": "2020-06-28T19:45:00.000Z",
            "slot": 15,
            "cust_per_slot": 3,
            "status": "UPCOMING"
        }
    ]
}''');

    List<Reception> _receptions = [];
    for (var element in response['counters']) {
      _receptions.add(Reception.fromJson(Map<String, dynamic>.from(element)));
    }
    receptionList = _receptions;
    /*
    String accessToken = await getAccessTokenFromStorage();
    List<Reception> _receptions =
        await _appointmentRepository.viewReceptionsByStatus(
      subscriberId: subscriberId,
      status: ['UPCOMING', 'ACTIVE'],
      accessToken: accessToken,
    );*/
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
  }
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
