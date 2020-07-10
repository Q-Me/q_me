import 'dart:async';
import 'dart:developer';

import 'package:qme/api/base_helper.dart';
import 'package:qme/model/queue.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/repository/queue.dart';

class SubscriberBloc {
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
  Stream<ApiResponse<List<Reception>>> get receptionListStream =>
      _receptionListController.stream;

  SubscriberBloc(this.subscriberId) {
    _queuesListController = StreamController<ApiResponse<List<Queue>>>();
    _receptionListController = StreamController<ApiResponse<List<Reception>>>();

    _queuesRepository = QueuesListRepository();
    _appointmentRepository = AppointmentRepository();

//    fetchQueuesList();

    // fetchReceptions and their slots
    fetchReceptions();
  }
  fetchReceptions() async {
    receptionListSink.add(ApiResponse.loading('Fetching appointment slots'));

    try {
      final String accessToken = await getAccessTokenFromStorage();
      List<Reception> _receptions =
          await _appointmentRepository.viewReceptionsByStatus(
        subscriberId: subscriberId,
        status: ['UPCOMING', 'ACTIVE'],
        accessToken: accessToken,
      );
      // slots from start time and send and slot duration
      for (int i = 0; i < receptionList.length; i++) {
        Reception reception = receptionList[i];
        reception.createSlots();
      }
      receptionList = _receptions;

      receptionListSink.add(ApiResponse.completed(receptionList));
    } on Exception catch (e) {
      log('Error in SubscriberBLOC:fetchExceptions:${e.toString()}');
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

void main() {
  SubscriberBloc subscriberBloc = SubscriberBloc('');
  subscriberBloc.fetchReceptions();
  for (Reception reception in subscriberBloc.receptionList) {
    print('${reception.toJson()}');
  }
}
