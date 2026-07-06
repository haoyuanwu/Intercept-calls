import 'package:flutter/material.dart';

import '../application/screening_controller.dart';
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
              selectedIcon: Icon(Icons.shield),
              label: '防护',
            ),
            NavigationDestination(icon: Icon(Icons.tune), label: '规则'),
            NavigationDestination(
              icon: Icon(Icons.contact_phone_outlined),
              label: '号码',
            ),
            NavigationDestination(
              icon: Icon(Icons.verified_outlined),
              selectedIcon: Icon(Icons.verified),
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
          builder: (context, _) => Scaffold(
            appBar: AppBar(title: Text('来电记录（${controller.records.length}）')),
            body: RecordsPage(
              records: controller.records,
              onRefresh: controller.load,
              onClear: controller.clearRecords,
            ),
          ),
        ),
      ),
    );
  }
}
