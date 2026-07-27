import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'application/screening_controller.dart';
import 'data/platform/native_screening_data_source.dart';
import 'data/repositories/platform_screening_repository.dart';
import 'domain/repositories/screening_repository.dart';
import 'presentation/main_screen.dart';
import 'presentation/theme/design_tokens.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '清净来电',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: T.brand,
          brightness: Brightness.light,
          primary: T.brand,
          surface: T.surface,
          error: T.danger,
          tertiary: T.info,
        ).copyWith(
          // 显式覆盖 on* 前景色 — 防止 fromSeed 自动计算与手动 surface 不匹配导致文字偏浅
          onSurface: T.ink,
          onSurfaceVariant: T.inkMuted,
          outline: T.inkSubtle,
          outlineVariant: T.hairline,
          primaryContainer: T.brandSoft,
          onPrimaryContainer: T.onBrandSoft,
          secondaryContainer: T.brandSoft,
          onSecondaryContainer: T.onBrandSoft,
        ),
        scaffoldBackgroundColor: T.surface,
        extensions: const [AppRadius()],
        // ── Typography ── 精炼字阶，层次更清晰（显式 color 防止继承偏浅色）
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
            color: T.ink,
          ),
          headlineMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            height: 1.2,
            color: T.ink,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: T.ink,
          ),
          titleLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: T.ink,
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: T.ink,
          ),
          titleSmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: T.ink,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: T.ink,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: T.inkMuted,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.45,
            color: T.inkMuted,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: T.ink,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            height: 1.2,
            color: T.inkMuted,
          ),
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: T.ink,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: T.ink,
            letterSpacing: -0.2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: T.card,
          shadowColor: Colors.black.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusT.md),
            side: const BorderSide(color: T.hairlineLight, width: 1),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: T.hairlineLight,
          thickness: 1,
          space: 1,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusT.sm),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: T.brand,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusT.sm),
            ),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusT.lg),
          ),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: T.ink,
          ),
          contentTextStyle: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: T.inkMuted,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusT.sm),
            borderSide: const BorderSide(color: T.hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusT.sm),
            borderSide: const BorderSide(color: T.brand, width: 2),
          ),
          filled: true,
          fillColor: T.card,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusT.xs),
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          backgroundColor: T.brandSoft,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: T.onBrandSoft,
          ),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          minLeadingWidth: 0,
          titleTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: T.ink,
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 13,
            color: T.inkMuted,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 64,
          elevation: 0,
          backgroundColor: Colors.white.withValues(alpha: 0.92),
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final base = const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
            return states.contains(WidgetState.selected)
                ? base.copyWith(color: T.brand, fontWeight: FontWeight.w700)
                : base.copyWith(color: T.inkSubtle);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return IconThemeData(
              size: 23,
              color: states.contains(WidgetState.selected)
                  ? T.brand
                  : T.inkSubtle,
            );
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusT.sm),
          ),
        ),
      ),
      home: MainScreen(controller: controller),
    );
  }
}
