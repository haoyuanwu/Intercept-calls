import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'application/screening_controller.dart';
import 'data/platform/native_screening_data_source.dart';
import 'data/repositories/platform_screening_repository.dart';
import 'domain/repositories/screening_repository.dart';
import 'presentation/main_screen.dart';

class CleanCallApp extends StatefulWidget {
  const CleanCallApp({super.key, this.repository});
  final ScreeningRepository? repository;

  @override
  State<CleanCallApp> createState() => _CleanCallAppState();
}

class _CleanCallAppState extends State<CleanCallApp> {
  late final ScreeningController controller;

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ??
        PlatformScreeningRepository(NativeScreeningDataSource());
    controller = ScreeningController(repository);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF176B5B);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '清净来电',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
          surface: const Color(0xFFF7F9F7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F6F3),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      home: MainScreen(controller: controller),
    );
  }
}
