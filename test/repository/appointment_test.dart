import 'package:qme/model/appointment.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/repository/appointment.dart';
import 'package:test/test.dart';

final String accessToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IkVZRkpGbWlnMCIsIm5hbWUiOiJQaXl1c2giLCJwaG9uZSI6Iis5MTk2NzM1ODI1MTciLCJpc1VzZXIiOnRydWUsImlhdCI6MTU5ODI0ODc0NywiZXhwIjoxNTk4MzM1MTQ3fQ.6eoe6dKX99U-Af6bOAze6cbKeYD3fnuooYJgX_wjZmI';
void main() {
  final AppointmentRepository repository = AppointmentRepository(
    localAccessToken: accessToken,
  );
  test('getReceptionAppointments', () async {
    final receptionId = "ClxpQ2WZT";
    final appointments = await repository.getReceptionAppointments(
        receptionId: receptionId, status: "ALL");
    expect(
      appointments,
      List<Appointment>.from(
        [
          Appointment.fromMap({
            "subscriber": "Piyush Saloon",
            "longitude": 0,
            "latitude": 0,
            "phone": "+919876543210",
            "address": "Mumbai",
            "category": "Beauty & Wellness",
            "verified": 0,
            "profileImage": null,
            "counter_starttime": "2020-08-21T06:00:00.000Z",
            "counter_endtime": "2020-08-21T10:00:00.000Z",
            "counter_status": "UPCOMING",
            "subscriber_id": "nplhS-7cJ",
            "counter_id": "ClxpQ2WZT",
            "slot_starttime": "2020-08-21T09:00:00.000Z",
            "slot_endtime": "2020-08-21T09:30:00.000Z",
            "slot_status": "UPCOMING",
            "note": "",
            "otp": 7140,
            "rating": null,
            "reviewed_by_user": 0
          })
        ],
      ),
    );
  });

  group('getDetailedReception', () {
    test('with json', () {
      Reception reception = Reception(
        id: "s54ii60Fw",
        subscriberId: "nplhS-7cJ",
        startTime: DateTime.utc(2020, 8, 25, 16),
        endTime: DateTime.utc(2020, 8, 25, 18),
        duration: Duration(hours: 1),
        custPerSlot: 3,
        status: "UPCOMING",
      );
      reception.addSlotList(List<Slot>.from([
        Slot(
          startTime: DateTime.utc(2020, 8, 25, 16),
          endTime: DateTime.utc(2020, 8, 25, 17),
          booked: false,
          upcoming: 0,
          done: 0,
          customersInSlot: 3,
        ),
        Slot(
          startTime: DateTime.utc(2020, 8, 25, 17),
          endTime: DateTime.utc(2020, 8, 25, 18),
          booked: false,
          upcoming: 0,
          done: 0,
          customersInSlot: 3,
        ),
      ]));

      expect(
        Reception.fromJson({
          "counter": {
            "id": "s54ii60Fw",
            "subscriber_id": "nplhS-7cJ",
            "starttime": "2020-08-25T16:00:00.000Z",
            "endtime": "2020-08-25T18:00:00.000Z",
            "slot": 60,
            "cust_per_slot": 3,
            "status": "UPCOMING",
            "repeat_till": "2000-01-01T00:00:00.000Z",
            "schedule_id": "NULL"
          },
          "slots_upcoming": [],
          "slots_done": [],
          "overrides": []
        }),
        reception,
      );
    });
  });
}
