import 'dart:async';

import 'package:battery_info/model/android_battery_info.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:battery_info/enums/charging_status.dart';
part 'battery_block_event.dart';
part 'battery_block_state.dart';

class BatteryBlockBloc extends Bloc<BatteryBlockEvent, BatteryBlockState> {
  final BatteryInfoPlugin? batteryDetails;
  final String health;
  final int? batteryLevel;
  StreamSubscription? batteryStream;

  BatteryBlockBloc(
      {@required this.batteryDetails, this.health = '', this.batteryStream,this.batteryLevel})
      : super(BatteryBlockState()) {
    on<GetHealth>((event, emit) async {
      emit(state.copyWith(
          health: (await batteryDetails?.androidBatteryInfo)?.health,
          batteryLevel: (await batteryDetails?.androidBatteryInfo)?.batteryLevel));
    });
  }
}
