import 'package:flutter/services.dart';

abstract interface class ScreeningDataSource {
  Future<Map<String, dynamic>> getStatus();
  Future<Map<String, dynamic>> getSettings();
  Future<List<Map<String, dynamic>>> getRecords();
  Future<void> saveSettings(Map<String, dynamic> settings);
  Future<bool> requestRole();
  Future<void> openSettings();
  Future<void> clearRecords();
}

class NativeScreeningDataSource implements ScreeningDataSource {
  NativeScreeningDataSource({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'telephone_interception/call_screening';
  final MethodChannel _channel;

  @override
  Future<Map<String, dynamic>> getStatus() async => Map<String, dynamic>.from(
    await _channel.invokeMapMethod<String, dynamic>('getStatus') ?? {},
  );

  @override
  Future<Map<String, dynamic>> getSettings() async => Map<String, dynamic>.from(
    await _channel.invokeMapMethod<String, dynamic>('getSettings') ?? {},
  );

  @override
  Future<List<Map<String, dynamic>>> getRecords() async =>
      (await _channel.invokeListMethod<dynamic>('getLogs') ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) =>
      _channel.invokeMethod<void>('saveSettings', settings);

  @override
  Future<bool> requestRole() async =>
      await _channel.invokeMethod<bool>('requestRole') ?? false;

  @override
  Future<void> openSettings() => _channel.invokeMethod<void>('openSettings');

  @override
  Future<void> clearRecords() => _channel.invokeMethod<void>('clearLogs');
}
