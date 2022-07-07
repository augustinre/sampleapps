part of 'battery_block_bloc.dart';

abstract class BatteryBlockEvent extends Equatable {

}

class GetHealth extends BatteryBlockEvent{
  @override
  List<Object> get props => [];

}