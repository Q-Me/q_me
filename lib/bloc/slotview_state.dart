part of 'slotview_bloc.dart';

abstract class SlotViewState extends Equatable {
  const SlotViewState();

  @override
  List<Object> get props => [];
}

class SlotViewStateInitial extends SlotViewState {
  final String subscriberId;

  SlotViewStateInitial(this.subscriberId);

  @override
  List<Object> get props => [subscriberId];
}

class SlotViewLoading extends SlotViewState {}

class NothingSelected extends SlotViewState {
  final response;

  NothingSelected(this.response);

  @override
  List<Object> get props => [response];
}

class BookedSlot extends SlotViewState {
  final Slot slot;
  final Reception reception;
  final String subcriberId;

  BookedSlot({
    @required this.slot,
    @required this.reception,
    @required this.subcriberId,
  });

  @override
  List<Object> get props => [slot, reception, subcriberId];
}

class SelectedSlot extends SlotViewState {
  final Slot slot;
  final Reception reception;
  final Subscriber subcriber;

  SelectedSlot({
    @required this.slot,
    @required this.reception,
    @required this.subcriber,
  });

  @override
  List<Object> get props => [slot, reception, subcriber];
}

class SlotViewLoadFail extends SlotViewState {
  final String message;

  SlotViewLoadFail(this.message);

  @override
  List<Object> get props => [message];
}
