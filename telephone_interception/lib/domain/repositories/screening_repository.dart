import '../models/call_record.dart';
import '../models/screening_settings.dart';
import '../models/screening_status.dart';

abstract interface class ScreeningRepository {
  Future<ScreeningStatus> getStatus();
  Future<ScreeningSettings> getSettings();
  Future<List<CallRecord>> getRecords();
  Future<void> saveSettings(ScreeningSettings settings);
  Future<bool> requestScreeningRole();
  Future<void> openSystemSettings();
  Future<void> clearRecords();
}
