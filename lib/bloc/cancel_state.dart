part of 'cancel_bloc.dart';

abstract class CancelState extends Equatable {
  const CancelState();
  @override
  List<Object> get props => [];
}

class CancelInitial extends CancelState {}

class CancelLoadInProgress extends CancelState {}

class CancelSuccess extends CancelState {
  final String msg;
  CancelSuccess(this.msg) : assert(msg != null);

  @override
  List<Object> get props => [msg];
}

class CancelLoadFailure extends CancelState {}
