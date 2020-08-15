import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';

List<Slot> createSlotsFromDuration(Reception reception) {
  List<Slot> slots = [];
  for (int i = 0;
      i < reception.endTime.difference(reception.startTime).inMinutes;
      i += reception.duration.inMinutes) {
    slots.add(
      Slot(
        startTime: reception.startTime.add(Duration(minutes: i)),
        endTime: reception.startTime
            .add(Duration(minutes: i + reception.duration.inMinutes)),
        customersInSlot: reception.custPerSlot,
      ),
    );
  }
  return slots;
}
