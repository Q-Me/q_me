import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:test/test.dart';

void main() {
  group('Reception from Json', () {
    test('only counter', () {
      Map<String, dynamic> json = {
        "id": "Iqh52Qtji",
        "subscriber_id": "17dY6K8Hb",
        "starttime": "2020-06-29T15:00:00.000Z",
        "endtime": "2020-06-29T19:00:00.000Z",
        "slot": 15,
        "cust_per_slot": 1,
        "status": "UPCOMING"
      };

      expect(
          Reception.fromJson(json),
          Reception(
            id: "Iqh52Qtji",
            subscriberId: "17dY6K8Hb",
            startTime: DateTime.utc(2020, 6, 29, 15),
            endTime: DateTime.utc(2020, 6, 29, 19),
            custPerSlot: 1,
            duration: Duration(minutes: 15),
            status: "UPCOMING",
          ));
    });

    test('detailed reception', () {
      Map<String, dynamic> json = {
        "counter": {
          "id": "rGhgIVVpR",
          "subscriber_id": "g67eUMo8l",
          "starttime": "2020-08-11T15:00:00.000Z",
          "endtime": "2020-08-11T18:00:00.000Z",
          "slot": 60,
          "cust_per_slot": 2,
          "status": "UPCOMING",
          "repeat_till": "2000-01-01T00:00:00.000Z",
          "schedule_id": "NULL"
        },
        "slots_upcoming": [
          {"starttime": "2020-08-11T16:00:00.000Z", "count": 2},
          {"starttime": "2020-08-11T17:00:00.000Z", "count": 1}
        ],
        "slots_done": [
          {"starttime": "2020-08-11T15:00:00.000Z", "count": 2}
        ],
        "overrides": [
          {
            "counter_id": "Iqh52Qtji",
            "starttime": "2020-08-11T16:00:00.000Z",
            "endtime": "2020-08-11T17:00:00.000Z",
            "override": 0
          },
          {
            "counter_id": "Iqh52Qtji",
            "starttime": "2020-06-29T18:00:00.000Z",
            "endtime": "2020-06-29T19:00:00.000Z",
            "override": 0
          }
        ]
      };
      final DateTime start2 = DateTime.utc(2020, 8, 11, 15);

      final Reception reception = Reception(
        id: "rGhgIVVpR",
        subscriberId: "g67eUMo8l",
        startTime: start2,
        endTime: start2.add(Duration(hours: 3)),
        duration: Duration(hours: 1),
        custPerSlot: 2,
        status: "UPCOMING",
      );
      reception.addSlotList(
        List<Slot>.from([
          Slot(
            startTime: start2,
            endTime: start2.add(Duration(hours: 1)),
            upcoming: 0,
            done: 2,
            customersInSlot: 2,
          ),
          Slot(
            startTime: start2.add(Duration(hours: 1)),
            endTime: start2.add(Duration(hours: 2)),
            upcoming: 2,
            customersInSlot: 0,
            done: 0,
          ),
          Slot(
            startTime: start2.add(Duration(hours: 2)),
            endTime: start2.add(Duration(hours: 3)),
            upcoming: 1,
            customersInSlot: 2,
            done: 0,
          ),
        ]),
      );
      expect(
        Reception.fromJson(json),
        reception,
      );
    });
  });
}
