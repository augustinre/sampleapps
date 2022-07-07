part of 'battery_block_bloc.dart';

class BatteryBlockState extends Equatable {
  final String health;
  final int? batteryLevel;
  const BatteryBlockState({this.health = '',this.batteryLevel});

  BatteryBlockState copyWith({
    String? health,
    int? batteryLevel,
  }) {
    return BatteryBlockState(
        health: health ?? this.health,
        batteryLevel: batteryLevel ?? this.batteryLevel);
  }

  @override
  List<dynamic> get props => [health,batteryLevel];
}

// 