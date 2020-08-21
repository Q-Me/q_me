import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/utilities/logger.dart';

part 'slotview_event.dart';
part 'slotview_state.dart';

class SlotViewBloc extends Bloc<SlotViewEvent, SlotViewState> {
  AppointmentRepository repository;
  final String subscriberId;
  List<Reception> datedReceptions;
  final String accessToken;



  SlotViewBloc({@required this.subscriberId, this.accessToken})
      : super(SlotViewStateInitial(subscriberId)) {
    repository = AppointmentRepository(
      localAccessToken: accessToken,
    );
  }


  @override
  Stream<SlotViewState> mapEventToState(SlotViewEvent event) async* {
    yield SlotViewLoading();
    if (event is DatedReceptionsRequested) {
      yield* _mapDatedReceptionRequested(event);
    }
    if (event is ReceptionDetailedRequested) {
      yield* _mapReceptionDetailedRequested(event);
    }
    if (event is ReceptionAppointmentsRequested) {}
  }

  Stream<SlotViewState> _mapDatedReceptionRequested(
      DatedReceptionsRequested event) async* {
    yield SlotViewLoading();
    logger.d('${event.date}');
    try {
      datedReceptions = await repository.getDatedReceptions(
        subscriberId: subscriberId,
        status: ["UPCOMING", "ACTIVE"],
        date: event.date,
      );
      yield SlotViewLoadSuccess(datedReceptions);
    } catch (e) {
      logger.e(e.toString());
      final msg = e.toString();
      yield SlotViewLoadFail(msg);
    }
  }

  _mapReceptionDetailedRequested(ReceptionDetailedRequested event) {
    // try{
    //   repository.de
    // }catch{}
  }
}
