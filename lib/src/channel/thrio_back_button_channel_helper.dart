import 'package:flutter/services.dart';

class ThrioBackButtonChannelHelper {
  static const _channel = OptionalMethodChannel('com.foxsofter.flutter_thrio/backbutton');

  static Future<void> enableBackButtonPressed() {
    return _channel.invokeMethod('enable');
  }

  static Future<void> disaableBackButtonPressed() {
    return _channel.invokeMethod('disable');
  }
}