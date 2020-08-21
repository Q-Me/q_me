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

class SlotViewLoadSuccess extends SlotViewState {
  final response;

  SlotViewLoadSuccess(this.response);
}

class SlotViewLoadFail extends SlotViewState {
  final String message;

  SlotViewLoadFail(this.message);
}
