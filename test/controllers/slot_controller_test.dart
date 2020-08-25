import 'package:qme/controllers/slot_controller.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:test/test.dart';

final DateTime start = DateTime(2020, 9, 5, 2);
final DateTime endSlot = DateTime(2020, 9, 5, 4);
final after = Slot(
  startTime: DateTime(2020, 9, 5, 2),
  endTime: DateTime(2020, 9, 5, 4),
);
final prev = Slot(
  startTime: DateTime(2020, 9, 5, 0),
  endTime: DateTime(2020, 9, 5, 2),
);
void main() {
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

  group('Slots list ordering', () {
    test('continous slot ordering', () {
      expect(
        orderSlotsByStartTime(List<Slot>.from([after, prev])),
        List<Slot>.from([prev, after]),
      );
    });

    test('ordered slots ordering', () {
      expect(
        orderSlotsByStartTime(List<Slot>.from([prev, after])),
        List<Slot>.from([prev, after]),
      );
    });
  });
  group('Slots overrides', () {
    test('Override slot creation', () {
      final overrides = createOverrideSlots(json);
      expect(
        overrides,
        List<Slot>.from(
          [
            Slot(
              startTime: DateTime.utc(2020, 6, 29, 16),
              endTime: DateTime.utc(2020, 6, 29, 17),
              customersInSlot: 0,
            ),
            Slot(
              startTime: DateTime.utc(2020, 6, 29, 18),
              endTime: DateTime.utc(2020, 6, 29, 19),
              customersInSlot: 0,
            ),
          ],
        ),
      );
    });

    test(
        'from slot list w/o reception json w/ override jsons in and outside reception range',
        () {
      Reception reception = Reception(
        startTime: DateTime.utc(2020, 8, 11, 15),
        endTime: DateTime.utc(2020, 8, 11, 18),
        custPerSlot: 2,
        duration: Duration(minutes: 60),
        id: null,
        status: null,
        subscriberId: null,
      );
      List<Slot> slotList = createSlotsFromDuration(reception);
      List<Slot> overrides = createOverrideSlots(json);

      expect(
        overrideSlots(slotList, overrides),
        List<Slot>.from(
          [
            Slot(
              startTime: DateTime.utc(2020, 8, 11, 15),
              endTime: DateTime.utc(2020, 8, 11, 16),
              customersInSlot: 2,
            ),
            Slot(
              startTime: DateTime.utc(2020, 8, 11, 16),
              endTime: DateTime.utc(2020, 8, 11, 17),
              customersInSlot: 0,
            ),
            Slot(
              startTime: DateTime.utc(2020, 8, 11, 17),
              endTime: DateTime.utc(2020, 8, 11, 18),
              customersInSlot: 2,
            ),
          ],
        ),
      );
    });
    test('from slot list w/ Reception json', () {
      Reception reception = Reception.fromJson(json["counter"]);
      List<Slot> slotList = createSlotsFromDuration(reception);
      List<Slot> overrides = createOverrideSlots(json);

      expect(
        overrideSlots(slotList, overrides),
        List<Slot>.from(
          [
            Slot(
              startTime: DateTime.utc(2020, 8, 11, 15),
              endTime: DateTime.utc(2020, 8, 11, 16),
              customersInSlot: 2,
            ),
            Slot(
              startTime: DateTime.utc(2020, 8, 11, 16),
              endTime: DateTime.utc(2020, 8, 11, 17),
              customersInSlot: 0,
            ),
            Slot(
              startTime: DateTime.utc(2020, 8, 11, 17),
              endTime: DateTime.utc(2020, 8, 11, 18),
              customersInSlot: 2,
            ),
          ],
        ),
      );
    });
  });

  group('Upcoming appointments modification', () {
    test('from json', () {
      List<Map<String, dynamic>> bookings = [
        {"starttime": "2020-08-11T16:00:00.000Z", "count": 2},
        {"starttime": "2020-08-11T17:00:00.000Z", "count": 1}
      ];
      final start1 = DateTime.utc(2020, 8, 11, 15);
      List<Slot> slots = List.generate(
        3,
        (index) => Slot(
          startTime: start1.add(Duration(hours: index)),
          endTime: start1.add(Duration(hours: index + 1)),
          customersInSlot: 3,
        ),
      );

      expect(
        modifyBookings(slots, bookings),
        List<Slot>.from(
          [
            Slot(
              startTime: DateTime.utc(2020, 8, 11, 15),
              endTime: DateTime.utc(2020, 8, 11, 16),
              customersInSlot: 3,
              upcoming: 0,
            ),
            Slot(
              startTime: DateTime.utc(2020, 8, 11, 16),
              endTime: DateTime.utc(2020, 8, 11, 17),
              customersInSlot: 3,
              upcoming: 2,
            ),
            Slot(
              startTime: DateTime.utc(2020, 8, 11, 17),
              endTime: DateTime.utc(2020, 8, 11, 18),
              customersInSlot: 3,
              upcoming: 1,
            ),
          ],
        ),
      );
    });
  });

  group('Done appointments modification', () {
    test('from json', () {
      List<Map<String, dynamic>> bookings = [
        {"starttime": "2020-08-11T16:00:00.000Z", "count": 2},
        {"starttime": "2020-08-11T17:00:00.000Z", "count": 1}
      ];
      final start1 = DateTime.utc(2020, 8, 11, 15);
      List<Slot> slots = List.generate(
        3,
        (index) => Slot(
          startTime: start1.add(Duration(hours: index)),
          endTime: start1.add(Duration(hours: index + 1)),
          customersInSlot: 3,
        ),
      );

      expect(
        modifyDoneSlots(slots, bookings),
        List<Slot>.from(
          [
            Slot(
              startTime: start1,
              endTime: start1.add(Duration(hours: 1)),
              customersInSlot: 3,
              done: 0,
            ),
            Slot(
              startTime: start1.add(Duration(hours: 1)),
              endTime: start1.add(Duration(hours: 2)),
              customersInSlot: 3,
              done: 2,
            ),
            Slot(
              startTime: start1.add(Duration(hours: 2)),
              endTime: start1.add(Duration(hours: 3)),
              customersInSlot: 3,
              done: 1,
            ),
          ],
        ),
      );
    });
  });

  test('detailed reception w/ controllers', () {
    Reception reception = Reception.fromJson(json["counter"]);
    List<Slot> slots = reception.slotList;
    slots = overrideSlots(slots, createOverrideSlots(json));

    slots = modifyBookings(slots, json["slots_upcoming"]);
    slots = modifyDoneSlots(slots, json["slots_done"]);

    final DateTime start2 = DateTime.utc(2020, 8, 11, 15);
    for (int i = 0; i < slots.length; i++) {
      print(slots[i].toJson());
    }
    expect(
        slots,
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
        ]));
  });
}
