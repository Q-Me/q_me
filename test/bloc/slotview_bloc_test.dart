import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qme/bloc/slotview_bloc.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/utilities/logger.dart';

final String subscriberId = 'nplhS-7cJ';
final String accessToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IkVZRkpGbWlnMCIsIm5hbWUiOiJQaXl1c2giLCJwaG9uZSI6Iis5MTk2NzM1ODI1MTciLCJpc1VzZXIiOnRydWUsImlhdCI6MTU5ODE4NjU0MiwiZXhwIjoxNTk4MjcyOTQyfQ.1YwRfvpA8yChvIn9oe-wx4WuznH0TEvL-16NFOFCLe0';

void main() {
  group('Slot View Bloc Test', () {
    blocTest(
      'Initialise with Initial State',
      build: () => SlotViewBloc(
        subscriber: Subscriber(id: subscriberId),
        accessToken: accessToken,
      ),
      expect: [],
    );

    Reception reception = Reception.fromJson({
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
    });
    DateTime testDate = DateTime.utc(2020, 8, 25);
    reception.addSlotList(
      List<Slot>.from(
        [
          Slot(
            startTime: testDate.add(Duration(hours: 16)),
            endTime: testDate.add(Duration(hours: 17)),
            booked: true,
            customersInSlot: 3,
            done: 0,
            upcoming: 1,
          ),
          Slot(
            startTime: testDate.add(Duration(hours: 17)),
            endTime: testDate.add(Duration(hours: 18)),
            booked: false,
            customersInSlot: 3,
            done: 0,
            upcoming: 0,
          ),
        ],
      ),
    );
    blocTest(
      'Dated requested',
      build: () => SlotViewBloc(
        subscriber: Subscriber(id: subscriberId),
        accessToken: accessToken,
      ),
      act: (bloc) {
        for (Slot slot in reception.slotList) {
          logger.d('Expectation' + slot.toJson().toString());
        }

        return bloc.add(
          DatedReceptionsRequested(date: testDate),
        );
      },
      expect: [
        SlotViewLoading(),
        NothingSelected(List<Reception>.from([reception]))
      ],
    );
  });
}
