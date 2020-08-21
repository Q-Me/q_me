part of 'slotview_bloc.dart';


abstract class SlotViewEvent extends Equatable {
  const SlotViewEvent();
}

class DatedReceptionsRequested extends SlotViewEvent {
  final DateTime date;

  DatedReceptionsRequested({@required this.date});

  @override
  List<Object> get props => [date];
}

class ReceptionDetailedRequested extends SlotViewEvent {
  final String receptionId;

  ReceptionDetailedRequested(this.receptionId);

  @override
  List<Object> get props => [receptionId];
}

class ReceptionAppointmentsRequested extends SlotViewEvent {
  final String receptionId;
  final String status;

  ReceptionAppointmentsRequested({
    @required this.receptionId,
    @required this.status,
  });

  @override
  List<Object> get props => [receptionId, status];
}
