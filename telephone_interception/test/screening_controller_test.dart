import 'package:flutter_test/flutter_test.dart';
import 'package:telephone_interception/application/screening_controller.dart';
import 'package:telephone_interception/domain/models/call_record.dart';
import 'package:telephone_interception/domain/models/screening_settings.dart';
import 'package:telephone_interception/domain/models/screening_status.dart';
import 'package:telephone_interception/domain/repositories/screening_repository.dart';

void main() {
  test('loads typed state from repository', () async {
    final repository = _FakeRepository();
    final controller = ScreeningController(repository);

    await controller.load();

    expect(controller.isLoading, isFalse);
    expect(controller.errorMessage, isNull);
    expect(controller.status.roleHeld, isTrue);
    expect(controller.settings.blockFraud, isTrue);
  });

  test('rolls settings back when persistence fails', () async {
    final repository = _FakeRepository()..failSaving = true;
    final controller = ScreeningController(repository);
    await controller.load();

    await controller.updateSettings(
      controller.settings.copyWith(blockFraud: false),
    );

    expect(controller.settings.blockFraud, isTrue);
    expect(controller.takeNotice(), '保存失败');
  });
}

class _FakeRepository implements ScreeningRepository {
  bool failSaving = false;

  @override
  Future<ScreeningStatus> getStatus() async => const ScreeningStatus(
    supported: true,
    roleAvailable: true,
    roleHeld: true,
    androidSdk: 35,
  );

  @override
  Future<ScreeningSettings> getSettings() async => const ScreeningSettings();

  @override
  Future<List<CallRecord>> getRecords() async => const [];

  @override
  Future<void> saveSettings(ScreeningSettings settings) async {
    if (failSaving) throw StateError('save failed');
  }

  @override
  Future<bool> requestScreeningRole() async => true;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<void> clearRecords() async {}
}
