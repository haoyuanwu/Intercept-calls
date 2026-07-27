import 'package:flutter/material.dart';

import '../../domain/models/call_category.dart';
import '../../domain/models/screening_settings.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key, required this.settings, required this.onChanged});

  final ScreeningSettings settings;
  final ValueChanged<ScreeningSettings> onChanged;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, Spacing.xl),
    children: [
      const NoticeCard(
        icon: Icons.rule_rounded,
        text: '白名单优先，其次执行直接拦截与静音规则；未命中规则的号码默认放行。',
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => _showStrategyDialog(context),
          icon: const Icon(Icons.menu_book_outlined, size: 18),
          label: const Text('查看完整拦截策略'),
        ),
      ),
      Card(
        child: Column(
          children: [
            SwitchListTile(
              secondary: LeadingBadge(icon: Icons.auto_awesome_rounded, color: T.brand),
              title: const Text('内置智能规则'),
              subtitle: const Text('银行保护、境外、虚拟运营商及企业热线规则'),
              value: settings.builtInRulesEnabled,
              onChanged: (v) => onChanged(settings.copyWith(builtInRulesEnabled: v)),
            ),
            const Divider(height: 1, indent: 64),
            SwitchListTile(
              secondary: LeadingBadge(icon: Icons.replay_rounded, color: T.info),
              title: const Text('重复来电保护'),
              subtitle: const Text('灰名单号码 1 小时内第 3 次来电时放行'),
              value: settings.repeatedCallProtection,
              onChanged: settings.builtInRulesEnabled
                  ? (v) => onChanged(settings.copyWith(repeatedCallProtection: v))
                  : null,
            ),
          ],
        ),
      ),
      const SizedBox(height: Spacing.md),
      Card(
        child: Column(
          children: [
            _RuleSwitch(
              category: CallCategory.fraud,
              subtitle: '默认直接拒接并隐藏通知',
              value: settings.blockFraud,
              onChanged: (v) => onChanged(settings.copyWith(blockFraud: v)),
            ),
            const Divider(height: 1, indent: 64),
            _RuleSwitch(
              category: CallCategory.marketing,
              subtitle: '贷款、保险、房产及推销',
              value: settings.blockMarketing,
              onChanged: (v) => onChanged(settings.copyWith(blockMarketing: v)),
            ),
            const Divider(height: 1, indent: 64),
            _RuleSwitch(
              category: CallCategory.bank,
              subtitle: '建议放行，防止错过交易提醒',
              value: settings.blockBank,
              onChanged: (v) => onChanged(settings.copyWith(blockBank: v)),
            ),
            const Divider(height: 1, indent: 64),
            _RuleSwitch(
              category: CallCategory.carrier,
              subtitle: '移动、联通、电信等服务电话',
              value: settings.blockCarrier,
              onChanged: (v) => onChanged(settings.copyWith(blockCarrier: v)),
            ),
            const Divider(height: 1, indent: 64),
            _RuleSwitch(
              category: CallCategory.privateNumber,
              subtitle: '无法读取来电号码时执行拦截',
              value: settings.blockPrivate,
              onChanged: (v) => onChanged(settings.copyWith(blockPrivate: v)),
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _showStrategyDialog(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 22),
          SizedBox(width: Spacing.sm),
          Text('拦截策略说明'),
        ],
      ),
      content: const SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StrategySection(
                color: T.success,
                title: 'P2 · 优先放行',
                text: '用户白名单、内置银行官方号码，以及 5 位 955XX 银行短号。白名单命中后不再执行任何拦截规则。',
              ),
              _StrategySection(
                color: T.danger,
                title: 'P0 · 直接拦截',
                text: '用户黑名单和自定义号段；境外号码；170、171、162、165、167 虚拟运营商号段；952—959 开头且长度不少于 8 位的营销号码。',
              ),
              _StrategySection(
                color: T.warning,
                title: 'P1 · 静音处理',
                text: '400、1010 企业热线，10001、10085、10016 营销号码，以及未达到 P0 条件的 95 企业长号。来电不会响铃，但会保留记录。',
              ),
              _StrategySection(
                color: T.info,
                title: '重复来电保护',
                text: '同一灰名单号码在 1 小时内第 3 次来电时自动放行，避免错过可能的紧急联系。用户黑名单和自定义号段不会因此降级。',
              ),
              _StrategySection(
                color: Color(0xFF68747A),
                title: '默认策略',
                text: '未命中任何规则的号码正常放行。用户手动设置的规则优先于内置智能规则。',
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('我知道了')),
      ],
    ),
  );
}

class _StrategySection extends StatelessWidget {
  const _StrategySection({required this.color, required this.title, required this.text});
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: Spacing.sm),
            Text(title, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(text, style: const TextStyle(fontSize: 13, color: T.inkMuted, height: 1.5)),
      ],
    ),
  );
}

class _RuleSwitch extends StatelessWidget {
  const _RuleSwitch({
    required this.category,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final CallCategory category;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: LeadingBadge(icon: category.icon, color: category.color),
    title: Text(category.label),
    subtitle: Text(subtitle),
    value: value,
    onChanged: onChanged,
    contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: 3),
  );
}
