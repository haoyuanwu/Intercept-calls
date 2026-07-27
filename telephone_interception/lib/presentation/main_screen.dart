import 'package:flutter/material.dart';

import '../application/screening_controller.dart';
import '../domain/models/call_record.dart';
import 'pages/home_page.dart';
import 'pages/numbers_page.dart';
import 'pages/official_numbers_page.dart';
import 'pages/records_page.dart';
import 'pages/rules_page.dart';
import 'widgets/common_widgets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.controller});
  final ScreeningController controller;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedTab = 0;

  ScreeningController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) controller.load();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      _showPendingNotice();
      final pages = [
        HomePage(
          status: controller.status,
          settings: controller.settings,
          records: controller.records,
          onEnable: controller.requestRole,
          onSettingsChanged: controller.updateSettings,
          onOpenRecords: _openRecords,
          onDialRecord: _confirmAndDial,
        ),
        RulesPage(
          settings: controller.settings,
          onChanged: controller.updateSettings,
        ),
        NumbersPage(
          settings: controller.settings,
          onChanged: controller.updateSettings,
        ),
        const OfficialNumbersPage(),
      ];

      return Scaffold(
        appBar: AppBar(
          title: Text(['清净来电', '拦截规则', '号码管理', '平台号码'][_selectedTab]),
          backgroundColor: Colors.transparent,
          actions: [
            if (controller.isSaving)
              const Padding(
                padding: EdgeInsets.only(right: 18),
                child: Center(
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : controller.errorMessage != null
            ? ErrorState(
                message: controller.errorMessage!,
                onRetry: controller.load,
              )
            : IndexedStack(index: _selectedTab, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: (index) {
            setState(() => _selectedTab = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield_rounded),
              label: '防护',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_rounded),
              selectedIcon: Icon(Icons.tune_rounded),
              label: '规则',
            ),
            NavigationDestination(
              icon: Icon(Icons.contact_phone_outlined),
              selectedIcon: Icon(Icons.contact_phone_rounded),
              label: '号码',
            ),
            NavigationDestination(
              icon: Icon(Icons.verified_outlined),
              selectedIcon: Icon(Icons.verified_rounded),
              label: '平台',
            ),
          ],
        ),
      );
    },
  );

  void _showPendingNotice() {
    final message = controller.takeNotice();
    if (message == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  }

  Future<void> _openRecords() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ListenableBuilder(
          listenable: controller,
          builder: (ctx, _) => Scaffold(
            appBar: AppBar(
              title: Text('来电记录（${controller.records.length}）'),
              actions: [
                if (controller.records.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: '清空记录',
                    onPressed: () async {
                      final confirmed = await showActionConfirmation(
                        ctx,
                        title: '清空来电记录？',
                        message: '号码规则不会受到影响。',
                        confirmLabel: '清空',
                        destructive: true,
                      );
                      if (confirmed) await controller.clearRecords();
                    },
                  ),
              ],
            ),
            body: RecordsPage(
              records: controller.records,
              onRefresh: controller.load,
              onDialRecord: _confirmAndDial,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDial(CallRecord record) async {
    final confirmed = await showActionConfirmation(
      context,
      title: '回拨这个号码？',
      message: '将打开系统拨号界面并填入 ${record.number}，请确认号码无误后再拨出。',
      confirmLabel: '去拨号',
    );
    if (!confirmed) return;
    await controller.dialNumber(record.number);
  }
}
