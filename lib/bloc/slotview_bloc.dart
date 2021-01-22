import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/utilities/logger.dart';

part 'slotview_event.dart';
part 'slotview_state.dart';

class SlotViewBloc extends Bloc<SlotViewEvent, SlotViewState> {
  AppointmentRepository _repository;
  final Subscriber subscriber;
  DateTime selectedDate;
  List<Reception> datedReceptions;
  final String accessToken;
  Box box;
  SlotViewBloc({@required this.subscriber, this.accessToken, this.selectedDate})
      : super(SlotViewStateInitial(subscriber.id)) {
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
      selectedDate = event.date;
      datedReceptions = [];
      logger.d('Date requested ${event.date}');
      bool isGuest = getUserDataFromStorage().isGuest;

      try {
        datedReceptions = await _repository.getDatedReceptions(
          subscriberId: subscriber.id,
          status: ["UPCOMING", "ACTIVE"],
          date: event.date,
        );
      } catch (e) {
        logger.e(e.toString());
        final msg = e.toString();
        yield SlotViewLoadFail(msg);
      }

      // For each reception call detailed reception
      for (int i = 0;
          i < (datedReceptions.length == null ? 0 : datedReceptions.length);
          i++) {
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

        if (isGuest == false) {
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
          logger.d('Appointment for reception  $receptionId\n' +
              receptionAppointments.toString());

          if (receptionAppointments.length == 1) {
            Slot appointmentSlot = receptionAppointments[0].slot;
            final reception = datedReceptions[i];

            // if there is an appointment is UPCOMING disable this reception for booking
            datedReceptions[i].availableForBooking = false;
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
                reception.bookedSlot = slot;
                logger.d("Found matching slot for appointment" +
                    recpetionSlots[j].toJson().toString());
                break;
              }
            }
          }
        }

        /* 
        for (Slot slot in datedReceptions[i].slotList) {
          logger.d('From api slot ' + slot.toJson().toString());
        }
        */
      }
      if (datedReceptions.length == 1 &&
          datedReceptions[0].bookedSlot != null) {
        yield BookedSlot(
          slot: datedReceptions[0].bookedSlot,
          reception: datedReceptions[0],
          subcriberId: subscriber.id,
        );
      } else {
        yield NothingSelected(datedReceptions);
      }
    } else if (event is SelectSlot) {
      logger.i(
          'Selected slot in reception ${event.reception.id} is ${event.slot.toJson()}');
      yield SelectedSlot(
        reception: event.reception,
        slot: event.slot,
        subcriber: subscriber,
      );
    }
  }
}
