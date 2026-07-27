import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/models/call_record.dart';
import '../domain/models/screening_settings.dart';
import '../domain/models/screening_status.dart';
import '../domain/repositories/screening_repository.dart';

class ScreeningController extends ChangeNotifier {
  ScreeningController(this._repository);
  final ScreeningRepository _repository;
  int _loadRevision = 0;
  int _saveRevision = 0;

  ScreeningStatus status = const ScreeningStatus.unavailable();
  ScreeningSettings settings = const ScreeningSettings();
  List<CallRecord> records = const [];
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;
  String? noticeMessage;

  Future<void> load() async {
    final revision = ++_loadRevision;
    try {
      final results = await Future.wait<Object>([
        _repository.getStatus(),
        _repository.getSettings(),
        _repository.getRecords(),
      ]);
      if (revision != _loadRevision) return;
      status = results[0] as ScreeningStatus;
      settings = results[1] as ScreeningSettings;
      records = results[2] as List<CallRecord>;
      errorMessage = null;
    } on MissingPluginException {
      if (revision != _loadRevision) return;
      errorMessage = '来电拦截仅支持 Android 真机';
    } catch (error) {
      if (revision != _loadRevision) return;
      errorMessage = _messageOf(error, '读取系统状态失败');
    } finally {
      if (revision == _loadRevision) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateSettings(ScreeningSettings next) async {
    final revision = ++_saveRevision;
    final previous = settings;
    settings = next;
    isSaving = true;
    notifyListeners();
    try {
      await _repository.saveSettings(next);
    } catch (error) {
      if (revision == _saveRevision) {
        settings = previous;
        noticeMessage = _messageOf(error, '保存失败');
      }
    } finally {
      if (revision == _saveRevision) {
        isSaving = false;
        notifyListeners();
      }
    }
  }

  Future<void> requestRole() async {
    try {
      final granted = await _repository.requestScreeningRole();
      noticeMessage = granted ? '来电防护已启用' : '尚未取得来电筛选权限';
      await load();
    } catch (error) {
      noticeMessage = _messageOf(error, '无法申请来电筛选权限');
      await _repository.openSystemSettings();
      notifyListeners();
    }
  }

  Future<void> clearRecords() async {
    try {
      await _repository.clearRecords();
      records = const [];
      notifyListeners();
    } catch (error) {
      noticeMessage = _messageOf(error, '清空失败');
      notifyListeners();
    }
  }

  Future<void> dialNumber(String number) async {
    try {
      await _repository.dialNumber(number);
    } catch (error) {
      noticeMessage = _messageOf(error, '无法打开拨号界面');
      notifyListeners();
    }
  }

  String? takeNotice() {
    final message = noticeMessage;
    noticeMessage = null;
    return message;
  }

  static String _messageOf(Object error, String fallback) =>
      error is PlatformException ? error.message ?? fallback : fallback;
}
