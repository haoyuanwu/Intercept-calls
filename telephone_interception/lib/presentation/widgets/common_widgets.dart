import 'package:flutter/material.dart';

import '../../domain/models/call_category.dart';

Future<bool> showActionConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
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
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                  foregroundColor: Theme.of(dialogContext).colorScheme.onError,
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
    CallCategory.blacklist => Icons.block,
    CallCategory.blockedPrefix => Icons.filter_alt_off_outlined,
    CallCategory.graylist => Icons.notifications_off_outlined,
    CallCategory.whitelist => Icons.verified_outlined,
    CallCategory.fraud => Icons.gpp_bad_outlined,
    CallCategory.marketing => Icons.campaign_outlined,
    CallCategory.bank => Icons.account_balance_outlined,
    CallCategory.carrier => Icons.cell_tower_outlined,
    CallCategory.privateNumber => Icons.phone_locked_outlined,
    CallCategory.normal => Icons.phone_outlined,
  };

  Color get color => switch (this) {
    CallCategory.blacklist ||
    CallCategory.blockedPrefix ||
    CallCategory.fraud => const Color(0xFFD64545),
    CallCategory.whitelist => const Color(0xFF238B72),
    CallCategory.graylist => const Color(0xFFE4A12C),
    CallCategory.marketing => const Color(0xFFE4862C),
    CallCategory.bank => const Color(0xFF3F72AF),
    CallCategory.carrier || CallCategory.normal => const Color(0xFF68747A),
    CallCategory.privateNumber => const Color(0xFF7558A6),
  };
}

class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

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
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 62, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        const Icon(Icons.error_outline, size: 52),
        const SizedBox(height: 12),
        Text(message),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('重试')),
      ],
    ),
  );
}
