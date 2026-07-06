import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telephone_interception/app.dart';
import 'package:telephone_interception/domain/models/call_action.dart';
import 'package:telephone_interception/domain/models/call_category.dart';
import 'package:telephone_interception/domain/models/call_record.dart';
import 'package:telephone_interception/domain/models/screening_settings.dart';
import 'package:telephone_interception/domain/models/screening_status.dart';
import 'package:telephone_interception/domain/repositories/screening_repository.dart';

void main() {
  testWidgets('shows protection setup state', (tester) async {
    await tester.pumpWidget(
      CleanCallApp(repository: FakeScreeningRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('清净来电'), findsOneWidget);
    expect(find.text('防护尚未生效'), findsOneWidget);
    expect(find.text('立即开启系统权限'), findsOneWidget);
  });

  testWidgets('shows the complete strategy in a dialog', (tester) async {
    await tester.pumpWidget(
      CleanCallApp(repository: FakeScreeningRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('规则'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看完整拦截策略'));
    await tester.pumpAndSettle();

    expect(find.text('拦截策略说明'), findsOneWidget);
    expect(find.text('P2 · 优先放行'), findsOneWidget);
    expect(find.text('P0 · 直接拦截'), findsOneWidget);
    expect(find.text('P1 · 静音处理'), findsOneWidget);
  });

  testWidgets('shows records on home and opens the complete history', (
    tester,
  ) async {
    final repository = FakeScreeningRepository(
      records: [
        CallRecord(
          number: '17012345678',
          category: CallCategory.blockedPrefix,
          action: CallAction.block,
          reason: '命中用户号段 170',
          timestamp: DateTime.now(),
        ),
      ],
    );
    await tester.pumpWidget(CleanCallApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('最近来电'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('最近来电'), findsOneWidget);
    expect(find.text('17012345678'), findsOneWidget);
    expect(find.text('记录'), findsNothing);

    await tester.tap(find.text('查看全部 1'));
    await tester.pumpAndSettle();
    expect(find.text('来电记录（1）'), findsOneWidget);
  });

  testWidgets('previews prefixes and opens the complete list', (tester) async {
    final repository = FakeScreeningRepository(
      settings: const ScreeningSettings(
        blockedPrefixes: {'162', '165', '167', '170', '171', '400'},
      ),
    );
    await tester.pumpWidget(CleanCallApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('号码'));
    await tester.pumpAndSettle();

    expect(find.text('共 6 个'), findsOneWidget);
    expect(find.text('还有 2 个号段未显示'), findsOneWidget);

    await tester.tap(find.text('号段拦截'));
    await tester.pumpAndSettle();

    expect(find.text('号段拦截（6）'), findsOneWidget);
    expect(find.text('400*'), findsOneWidget);
  });

  testWidgets('previews individual numbers and opens the complete list', (
    tester,
  ) async {
    final repository = FakeScreeningRepository(
      settings: const ScreeningSettings(
        blacklist: {'10001', '10002', '10003'},
        whitelist: {'95588', '95566'},
        labels: {'4008009888': CallCategory.bank},
      ),
    );
    await tester.pumpWidget(CleanCallApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('号码'));
    await tester.pumpAndSettle();

    expect(find.text('共 6 个'), findsOneWidget);
    expect(find.text('还有 2 个号码未显示'), findsOneWidget);

    await tester.tap(find.text('单个号码'));
    await tester.pumpAndSettle();

    expect(find.text('单个号码（6）'), findsOneWidget);
    expect(find.text('4008009888'), findsOneWidget);
  });

  testWidgets('searches and copies an official platform number', (
    tester,
  ) async {
    await tester.pumpWidget(
      CleanCallApp(repository: FakeScreeningRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('平台'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('搜索平台号码'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), '10099');
    await tester.pumpAndSettle();

    expect(find.text('中国广电'), findsOneWidget);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
    await tester.tap(find.byTooltip('复制 10099'));
    await tester.pumpAndSettle();
    expect(find.text('已复制 中国广电：10099'), findsOneWidget);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
}

class FakeScreeningRepository implements ScreeningRepository {
  FakeScreeningRepository({
    this.settings = const ScreeningSettings(),
    this.records = const [],
  });

  ScreeningSettings settings;
  List<CallRecord> records;

  @override
  Future<void> clearRecords() async => records = const [];

  @override
  Future<List<CallRecord>> getRecords() async => records;

  @override
  Future<ScreeningSettings> getSettings() async => settings;

  @override
  Future<ScreeningStatus> getStatus() async => const ScreeningStatus(
    supported: true,
    roleAvailable: true,
    roleHeld: false,
    androidSdk: 35,
  );

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<bool> requestScreeningRole() async => true;

  @override
  Future<void> saveSettings(ScreeningSettings settings) async {
    this.settings = settings;
  }
}
