import 'package:flutter/material.dart';

import '../../domain/models/call_category.dart';
import '../../domain/models/screening_settings.dart';
import '../widgets/common_widgets.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key, required this.settings, required this.onChanged});

  final ScreeningSettings settings;
  final ValueChanged<ScreeningSettings> onChanged;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
    children: [
      NoticeCard(icon: Icons.rule, text: '白名单优先，其次执行直接拦截与静音规则；未命中规则的号码默认放行。'),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => _showStrategyDialog(context),
          icon: const Icon(Icons.menu_book_outlined),
          label: const Text('查看完整拦截策略'),
        ),
      ),
      Card(
        child: Column(
          children: [
            SwitchListTile(
              secondary: const CircleAvatar(child: Icon(Icons.auto_awesome)),
              title: const Text(
                '内置智能规则',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('银行保护、境外、虚拟运营商及企业热线规则'),
              value: settings.builtInRulesEnabled,
              onChanged: (value) =>
                  onChanged(settings.copyWith(builtInRulesEnabled: value)),
            ),
            const Divider(height: 1, indent: 68),
            SwitchListTile(
              secondary: const CircleAvatar(child: Icon(Icons.replay)),
              title: const Text(
                '重复来电保护',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('灰名单号码 1 小时内第 3 次来电时放行'),
              value: settings.repeatedCallProtection,
              onChanged: settings.builtInRulesEnabled
                  ? (value) => onChanged(
                      settings.copyWith(repeatedCallProtection: value),
                    )
                  : null,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: Column(
          children: [
            _RuleSwitch(
              category: CallCategory.fraud,
              subtitle: '默认直接拒接并隐藏通知',
              value: settings.blockFraud,
              onChanged: (value) =>
                  onChanged(settings.copyWith(blockFraud: value)),
            ),
            const Divider(height: 1, indent: 68),
            _RuleSwitch(
              category: CallCategory.marketing,
              subtitle: '贷款、保险、房产及推销',
              value: settings.blockMarketing,
              onChanged: (value) =>
                  onChanged(settings.copyWith(blockMarketing: value)),
            ),
            const Divider(height: 1, indent: 68),
            _RuleSwitch(
              category: CallCategory.bank,
              subtitle: '建议放行，防止错过交易提醒',
              value: settings.blockBank,
              onChanged: (value) =>
                  onChanged(settings.copyWith(blockBank: value)),
            ),
            const Divider(height: 1, indent: 68),
            _RuleSwitch(
              category: CallCategory.carrier,
              subtitle: '移动、联通、电信等服务电话',
              value: settings.blockCarrier,
              onChanged: (value) =>
                  onChanged(settings.copyWith(blockCarrier: value)),
            ),
            const Divider(height: 1, indent: 68),
            _RuleSwitch(
              category: CallCategory.privateNumber,
              subtitle: '无法读取来电号码时执行拦截',
              value: settings.blockPrivate,
              onChanged: (value) =>
                  onChanged(settings.copyWith(blockPrivate: value)),
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
          Icon(Icons.shield_outlined),
          SizedBox(width: 10),
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
                color: Color(0xFF238B72),
                title: 'P2 · 优先放行',
                text: '用户白名单、内置银行官方号码，以及 5 位 955XX 银行短号。白名单命中后不再执行任何拦截规则。',
              ),
              _StrategySection(
                color: Color(0xFFD64545),
                title: 'P0 · 直接拦截',
                text:
                    '用户黑名单和自定义号段；境外号码；170、171、162、165、167 虚拟运营商号段；952—959 开头且长度不少于 8 位的营销号码。',
              ),
              _StrategySection(
                color: Color(0xFFE4A12C),
                title: 'P1 · 静音处理',
                text:
                    '400、1010 企业热线，10001、10085、10016 营销号码，以及未达到 P0 条件的 95 企业长号。来电不会响铃，但会保留记录。',
              ),
              _StrategySection(
                color: Color(0xFF3F72AF),
                title: '重复来电保护',
                text:
                    '同一灰名单号码在 1 小时内第 3 次来电时自动放行，避免错过可能的紧急联系。用户黑名单和自定义号段不会因此降级。',
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
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('我知道了'),
        ),
      ],
    ),
  );
}

class _StrategySection extends StatelessWidget {
  const _StrategySection({
    required this.color,
    required this.title,
    required this.text,
  });
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(text),
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
    secondary: CircleAvatar(
      backgroundColor: category.color.withValues(alpha: .1),
      foregroundColor: category.color,
      child: Icon(category.icon),
    ),
    title: Text(
      category.label,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Text(subtitle),
    value: value,
    onChanged: onChanged,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
  );
}
