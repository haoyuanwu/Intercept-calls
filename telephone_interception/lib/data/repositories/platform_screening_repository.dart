import '../../domain/models/call_category.dart';
import '../../domain/models/call_action.dart';
import '../../domain/models/call_record.dart';
import '../../domain/models/screening_settings.dart';
import '../../domain/models/screening_status.dart';
import '../../domain/repositories/screening_repository.dart';
import '../platform/native_screening_data_source.dart';

class PlatformScreeningRepository implements ScreeningRepository {
  const PlatformScreeningRepository(this._dataSource);
  final ScreeningDataSource _dataSource;

  @override
  Future<ScreeningStatus> getStatus() async {
    final data = await _dataSource.getStatus();
    return ScreeningStatus(
      supported: data['supported'] == true,
      roleAvailable: data['roleAvailable'] == true,
      roleHeld: data['roleHeld'] == true,
      androidSdk: (data['sdk'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<ScreeningSettings> getSettings() async {
    final data = await _dataSource.getSettings();
    final rawLabels = Map<Object?, Object?>.from(
      data['labels'] as Map? ?? const {},
    );
    return ScreeningSettings(
      enabled: data['enabled'] != false,
      blockFraud: data['blockFraud'] != false,
      blockMarketing: data['blockMarketing'] != false,
      blockPrivate: data['blockPrivate'] == true,
      blockBank: data['blockBank'] == true,
      blockCarrier: data['blockCarrier'] == true,
      builtInRulesEnabled: data['builtInRulesEnabled'] != false,
      repeatedCallProtection: data['repeatedCallProtection'] != false,
      blacklist: _stringSet(data['blacklist']),
      whitelist: _stringSet(data['whitelist']),
      blockedPrefixes: _stringSet(data['blockedPrefixes']),
      labels: rawLabels.map(
        (key, value) =>
            MapEntry(key.toString(), CallCategory.fromWire(value?.toString())),
      ),
    );
  }

  @override
  Future<List<CallRecord>> getRecords() async =>
      (await _dataSource.getRecords())
          .map(
            (data) => CallRecord(
              number: data['number']?.toString() ?? '未知号码',
              category: CallCategory.fromWire(data['category']?.toString()),
              action: CallAction.fromWire(
                data['action']?.toString(),
                legacyBlocked: data['blocked'] == true,
              ),
              reason: data['reason']?.toString() ?? '',
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                (data['timestamp'] as num?)?.toInt() ?? 0,
              ),
            ),
          )
          .toList(growable: false);

  @override
  Future<void> saveSettings(ScreeningSettings settings) =>
      _dataSource.saveSettings({
        'enabled': settings.enabled,
        'blockFraud': settings.blockFraud,
        'blockMarketing': settings.blockMarketing,
        'blockPrivate': settings.blockPrivate,
        'blockBank': settings.blockBank,
        'blockCarrier': settings.blockCarrier,
        'builtInRulesEnabled': settings.builtInRulesEnabled,
        'repeatedCallProtection': settings.repeatedCallProtection,
        'blacklist': settings.blacklist.toList(),
        'whitelist': settings.whitelist.toList(),
        'blockedPrefixes': settings.blockedPrefixes.toList(),
        'labels': settings.labels.map(
          (number, category) => MapEntry(number, category.wireName),
        ),
      });

  @override
  Future<bool> requestScreeningRole() => _dataSource.requestRole();

  @override
  Future<void> openSystemSettings() => _dataSource.openSettings();

  @override
  Future<void> clearRecords() => _dataSource.clearRecords();

  static Set<String> _stringSet(Object? value) =>
      Set.unmodifiable((value as List? ?? const []).map((item) => '$item'));
}
