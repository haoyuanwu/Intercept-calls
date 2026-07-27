import 'package:flutter/material.dart';

import '../../domain/models/call_category.dart';
import '../theme/design_tokens.dart';

Future<bool> showActionConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final scheme = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('取消'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

extension CategoryPresentation on CallCategory {
  String get label => switch (this) {
    CallCategory.blacklist => '黑名单',
    CallCategory.blockedPrefix => '号段拦截',
    CallCategory.graylist => '可疑来电',
    CallCategory.whitelist => '白名单',
    CallCategory.fraud => '疑似诈骗',
    CallCategory.marketing => '营销推广',
    CallCategory.bank => '银行客服',
    CallCategory.carrier => '运营商客服',
    CallCategory.privateNumber => '隐藏号码',
    CallCategory.normal => '普通号码',
  };

  IconData get icon => switch (this) {
    CallCategory.blacklist => Icons.block_rounded,
    CallCategory.blockedPrefix => Icons.filter_alt_off_rounded,
    CallCategory.graylist => Icons.notifications_off_rounded,
    CallCategory.whitelist => Icons.verified_rounded,
    CallCategory.fraud => Icons.gpp_bad_rounded,
    CallCategory.marketing => Icons.campaign_rounded,
    CallCategory.bank => Icons.account_balance_rounded,
    CallCategory.carrier => Icons.cell_tower_rounded,
    CallCategory.privateNumber => Icons.phone_locked_rounded,
    CallCategory.normal => Icons.phone_rounded,
  };

  Color get color => switch (this) {
    CallCategory.blacklist ||
    CallCategory.blockedPrefix ||
    CallCategory.fraud => T.danger,
    CallCategory.whitelist => T.success,
    CallCategory.graylist => T.warning,
    CallCategory.marketing => const Color(0xFFE4862C),
    CallCategory.bank => T.info,
    CallCategory.carrier || CallCategory.normal => const Color(0xFF68747A),
    CallCategory.privateNumber => const Color(0xFF7558A6),
  };
}

/// ─────────────────────────────────────────────
/// 统一列表项左侧图标徽章
/// 尺寸 40×40，圆角 12，浅底深色，全应用一致
/// ─────────────────────────────────────────────
class LeadingBadge extends StatelessWidget {
  const LeadingBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize = 20,
  });
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(RadiusT.sm),
    ),
    child: Icon(icon, color: color, size: iconSize),
  );
}

/// ─────────────────────────────────────────────
/// 提示卡：浅底 + 左侧色条，克制不抢眼
/// ─────────────────────────────────────────────
class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.icon,
    required this.text,
    this.accent,
  });
  final IconData icon;
  final String text;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? T.brand;
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(RadiusT.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: T.inkMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// 空状态：圆形图标容器 + 标题 + 副标题
/// ─────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(Spacing.x2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.xl),
            decoration: BoxDecoration(
              color: T.brandSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: T.brand),
          ),
          const SizedBox(height: Spacing.base),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: T.ink,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: T.inkMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline_rounded, size: 48, color: T.danger),
        const SizedBox(height: Spacing.base),
        Text(message, style: TextStyle(fontSize: 14, color: T.inkMuted)),
        const SizedBox(height: Spacing.base),
        FilledButton(onPressed: onRetry, child: const Text('重试')),
      ],
    ),
  );
}

/// ─────────────────────────────────────────────
/// 区块标题：左标题 + 右操作
/// ─────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: T.ink,
          ),
        ),
        const Spacer(),
        ?action,
      ],
    ),
  );
}

/// ─────────────────────────────────────────────
/// 状态药丸：彩色浅底 + 同色粗体小字
/// ─────────────────────────────────────────────
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(RadiusT.pill),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
