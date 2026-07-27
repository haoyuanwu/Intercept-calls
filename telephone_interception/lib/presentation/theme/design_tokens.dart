import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────
/// 清净来电 · 设计令牌（唯一色值 / 字号 / 间距 / 圆角来源）
/// 所有页面与组件统一从此导入，禁止散落硬编码。
/// ─────────────────────────────────────────────

/// 品牌色板 ── 墨绿主色（信任 / 安全 / 清净）
class T {
  T._();

  // ── Brand ──
  static const brand = Color(0xFF176B5B);
  static const brandStrong = Color(0xFF0F5246);
  static const brandSoft = Color(0xFFE8F2EE);
  static const onBrandSoft = Color(0xFF0F5246);

  // ── Semantic ──
  static const danger = Color(0xFFD64545);
  static const dangerSoft = Color(0xFFFDEAEA);
  static const success = Color(0xFF238B72);
  static const successSoft = Color(0xFFE6F4F0);
  static const warning = Color(0xFFE4A12C);
  static const warningSoft = Color(0xFFFCF2E0);
  static const info = Color(0xFF3F72AF);
  static const infoSoft = Color(0xFFEAF1F8);

  // ── Neutral ──
  static const ink = Color(0xFF13211C);
  static const inkMuted = Color(0xFF60706A);
  static const inkSubtle = Color(0xFF94A39D);
  static const surface = Color(0xFFF4F7F5);
  static const card = Color(0xFFFFFFFF);
  static const hairline = Color(0xFFEAEFEC);
  static const hairlineLight = Color(0xFFF2F5F3);

  // ── Category palette ──
  // 诈骗/黑名单/号段 → danger
  // 白名单/银行 → success
  // 可疑 → warning
  // 营销 → Color(0xFFE4862C)
  // 银行客服 → info
  // 运营商/普通 → Color(0xFF68747A)
  // 隐藏号码 → Color(0xFF7558A6)
}

/// 间距令牌 ── 基于 4pt 网格
class Spacing {
  const Spacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const x2 = 32.0;
  static const x3 = 48.0;
}

/// 圆角令牌
class RadiusT {
  const RadiusT._();

  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const pill = 999.0;
}

/// 全局圆角 ThemeExtension（供 Theme 体系使用）
class AppRadius extends ThemeExtension<AppRadius> {
  const AppRadius({
    this.sm = 12.0,
    this.md = 16.0,
    this.lg = 20.0,
    this.pill = 999.0,
  });

  final double sm;
  final double md;
  final double lg;
  final double pill;

  @override
  AppRadius copyWith({double? sm, double? md, double? lg, double? pill}) =>
      AppRadius(
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        pill: pill ?? this.pill,
      );

  @override
  ThemeExtension<AppRadius> lerp(ThemeExtension<AppRadius>? other, double t) {
    if (other is! AppRadius) return this;
    return AppRadius(
      sm: sm + (other.sm - sm) * t,
      md: md + (other.md - md) * t,
      lg: lg + (other.lg - lg) * t,
      pill: pill + (other.pill - pill) * t,
    );
  }
}

/// ─────────────────────────────────────────────
/// 语义色查询快捷方法 ── 供 List / Switch 等统一引用
/// ─────────────────────────────────────────────

/// 拦截动作 → 语义色
Color actionColor(String action) => switch (action) {
      'block' => T.danger,
      'silence' => T.warning,
      _ => T.success,
};

/// 拦截动作 → 图标
IconData actionIcon(String action) => switch (action) {
      'block' => Icons.block_rounded,
      'silence' => Icons.notifications_off_rounded,
      _ => Icons.call_rounded,
};

/// 拦截动作 → 中文标签
String actionLabel(String action) => switch (action) {
      'block' => '已拦截',
      'silence' => '已静音',
      _ => '已放行',
};
