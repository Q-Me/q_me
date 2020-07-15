import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/user.dart';

class AppointmentRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<Reception>> viewReceptionsByStatus({
    @required subscriberId,
    @required List<String> status,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      '/user/slot/counters',
      req: {
        "subscriber_id": subscriberId,
        "status": status.length < 4 ? status : "ALL",
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    SplayTreeSet<Reception> _receptions = SplayTreeSet<Reception>(
        Comparing.on((Reception reception) => reception.startTime));
    for (var element in response['counters']) {
      _receptions.add(Reception.fromJson(Map<String, dynamic>.from(element)));
    }
    return _receptions.toList();
  }

  Future book({
    @required String counterId,
    @required String subscriberId,
    @required DateTime startTime,
    @required DateTime endTime,
    @required String note,
  }) async {
    final String accessToken = await getAccessTokenFromStorage();
    final response = await _helper.post(
      '/user/slot/book',
      req: {
        "counter_id": counterId,
        "subscriber_id": subscriberId,
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "note": note,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<List<Appointment>> fetchAppointments(
      {@required List<String> status, @required String accessToken}) async {
    final response = await _helper.post(
      '/user/slot/book',
      req: {
        "status": status.length < 4 ? status : "ALL",
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    final List<Appointment> appointments = List.from(response["slots"]
        .map((element) => Appointment.fromMap(Map.from(element))));
    return appointments;
  }

  Future<Reception> viewReception({
    @required String receptionId,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      '/user/slot/book',
      req: {"counter_id": receptionId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return Reception.fromJson(response);
  }

  Future addWish({@required receptionId, @required Slot slot}) async {
    final String _accessToken = await getAccessTokenFromStorage();

    final response = await _helper.post(
      '/user/slot/addwish',
      req: {
        "counter_id": receptionId,
        "starttime": [slot.startTime.toIso8601String()]
      },
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    return response;
  }

  Future removeWish({@required receptionId, @required Slot slot}) async {
    final String _accessToken = await getAccessTokenFromStorage();

    final response = await _helper.post(
      '/user/slot/removewish',
      req: {
        "counter_id": receptionId,
        "starttime": [slot.startTime.toIso8601String()]
      },
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    return response;
  }
}

void main() async {
  final String accessToken = '';
  AppointmentRepository appointmentRepository = AppointmentRepository();
  /*List<Appointment> aptms = await appointmentRepository.fetchAppointments();
  for (Appointment appointment in aptms) {
    print(appointment.toMap());
  }*/
  final Reception reception = await appointmentRepository.viewReception(
      receptionId: 'null', accessToken: 'f');
  print(reception.toJson());
}
