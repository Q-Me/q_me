import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/utilities/logger.dart';

part 'slotview_event.dart';
part 'slotview_state.dart';

class SlotViewBloc extends Bloc<SlotViewEvent, SlotViewState> {
  AppointmentRepository _repository;
  final String subscriberId;
  DateTime selectedDate;
  List<Reception> datedReceptions;
  final String accessToken;

  SlotViewBloc(
      {@required this.subscriberId, this.accessToken, this.selectedDate})
      : super(SlotViewStateInitial(subscriberId)) {
    _repository = AppointmentRepository(
      localAccessToken: accessToken,
    );
    // if (selectedDate != null) {
    //   this.add(DatedReceptionsRequested(date: selectedDate));
    // }
  }

  @override
  Stream<SlotViewState> mapEventToState(SlotViewEvent event) async* {
    yield SlotViewLoading();
    if (event is DatedReceptionsRequested) {
      yield SlotViewLoading();
      logger.d('Date requested ${event.date}');
      try {
        datedReceptions = await _repository.getDatedReceptions(
          subscriberId: subscriberId,
          status: ["UPCOMING", "ACTIVE"],
          date: event.date,
        );
      } catch (e) {
        logger.e(e.toString());
        final msg = e.toString();
        yield SlotViewLoadFail(msg);
      }

      // For each reception call detailed reception
      for (int i = 0; i < datedReceptions.length; i++) {
        final String receptionId = datedReceptions[i].id;
        try {
          datedReceptions[i] = await _repository.getDetailedReception(
            datedReceptions[i].id,
          );
        } catch (e) {
          final msg =
              "Error occured while geting details of reception:${datedReceptions[i].id}\n" +
                  e.toString();

          logger.e(msg);
          yield SlotViewLoadFail(msg);
          return;
        }

        // get any UPCOMING appointments for that reception
        List<Appointment> receptionAppointments = [];
        try {
          receptionAppointments = await _repository.getReceptionAppointments(
            receptionId: receptionId,
            status: ["UPCOMING"],
          );
        } catch (e) {
          final msg =
              "Error occured while geting appopintments of reception:${datedReceptions[i].id}\n" +
                  e.toString();

          logger.e(msg);
          yield SlotViewLoadFail(msg);
          return;
        }
        logger.d(receptionAppointments.toString());

        // if no appointment is UPCOMING enable this reception for booking
        if (receptionAppointments.length == 1) {
          Slot appointmentSlot = receptionAppointments[0].slot;
          final reception = datedReceptions[i];
          final recpetionSlots = reception.slotList;

          for (int j = 0; j < recpetionSlots.length; j++) {
            // get the corresponding booked slot from the reception
            Slot slot = recpetionSlots[j];
            if ((appointmentSlot.startTime.isAtSameMomentAs(slot.startTime) ||
                    appointmentSlot.startTime.isAfter(slot.startTime)) &&
                (appointmentSlot.endTime.isBefore(slot.endTime) ||
                    appointmentSlot.endTime.isAtSameMomentAs(slot.endTime))) {
              // disable booking for the slot
              recpetionSlots[j].booked = true;
              logger.d("Found matching slot for appointment" +
                  recpetionSlots[j].toJson().toString());
              break;
            }
          }
        }

        for (Slot slot in datedReceptions[i].slotList) {
          logger.d('From api slot ' + slot.toJson().toString());
        }
      }
      yield SlotViewLoadSuccess(datedReceptions);
    }
  }
}
