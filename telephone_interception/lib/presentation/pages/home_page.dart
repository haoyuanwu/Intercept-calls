import 'package:flutter/material.dart';

import '../../domain/models/call_action.dart';
import '../../domain/models/call_category.dart';
import '../../domain/models/call_record.dart';
import '../../domain/models/screening_settings.dart';
import '../../domain/models/screening_status.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.status,
    required this.settings,
    required this.records,
    required this.onEnable,
    required this.onSettingsChanged,
    required this.onOpenRecords,
    required this.onDialRecord,
  });

  final ScreeningStatus status;
  final ScreeningSettings settings;
  final List<CallRecord> records;
  final VoidCallback onEnable;
  final ValueChanged<ScreeningSettings> onSettingsChanged;
  final VoidCallback onOpenRecords;
  final ValueChanged<CallRecord> onDialRecord;

  @override
  Widget build(BuildContext context) {
    final active = status.roleHeld && settings.enabled;
    final now = DateTime.now();
    final blockedToday = records.where((item) {
      final time = item.timestamp;
      return item.blocked &&
          time.year == now.year &&
          time.month == now.month &&
          time.day == now.day;
    }).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, Spacing.xl),
      children: [
        // ── Hero ──
        _HeroCard(
          active: active,
          roleHeld: status.roleHeld,
          enabled: settings.enabled,
          onEnable: onEnable,
          onChanged: (v) => onSettingsChanged(settings.copyWith(enabled: v)),
        ),
        const SizedBox(height: Spacing.md),

        // ── Stats ──
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '$blockedToday',
                label: '今日拦截',
                icon: Icons.block_rounded,
                color: T.danger,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: _StatCard(
                value: '${records.length}',
                label: '筛选记录',
                icon: Icons.call_rounded,
                color: T.brand,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),

        // ── 当前策略 ──
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('当前策略', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: Spacing.sm),
                _PolicyRow(category: CallCategory.fraud, subtitle: '直接拒接并隐藏通知', blocked: settings.blockFraud),
                _PolicyRow(category: CallCategory.marketing, subtitle: '贷款、保险、房产及推销', blocked: settings.blockMarketing),
                _PolicyRow(category: CallCategory.bank, subtitle: '建议放行，防止错过交易提醒', blocked: settings.blockBank),
                _PolicyRow(category: CallCategory.carrier, subtitle: '移动、联通、电信等服务电话', blocked: settings.blockCarrier),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),

        // ── 最近来电 ──
        SectionHeader(
          title: '最近来电',
          action: records.isEmpty
              ? null
              : TextButton(onPressed: onOpenRecords, child: Text('查看全部 ${records.length}')),
        ),
        const SizedBox(height: Spacing.sm),
        if (records.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                icon: Icons.history_rounded,
                title: '暂无筛选记录',
                subtitle: '系统筛选来电后会显示在这里',
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < records.take(5).length; i++) ...[
                  _RecordTile(record: records[i], onDial: onDialRecord),
                  if (i != records.take(5).length - 1)
                    const Divider(height: 1, indent: 64),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// Hero 卡 ── 横向布局，信息层次更清晰
// ══════════════════════════════════════════════
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.active,
    required this.roleHeld,
    required this.enabled,
    required this.onEnable,
    required this.onChanged,
  });
  final bool active;
  final bool roleHeld;
  final bool enabled;
  final VoidCallback onEnable;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? const [T.brand, Color(0xFF1B8270)]
        : const [Color(0xFF6C7A75), Color(0xFF828F8A)];

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bg,
        ),
        borderRadius: BorderRadius.circular(RadiusT.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 顶行：盾牌 + 状态 ──
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(RadiusT.sm),
                ),
                child: Icon(
                  active ? Icons.shield_rounded : Icons.shield_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (active) ...[
                          const _PulseDot(),
                          const SizedBox(width: Spacing.xs),
                        ],
                        Text(
                          active ? '防护中' : '未生效',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleHeld ? '规则已在本机生效' : '需要设为系统来电筛选应用',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (roleHeld)
                Switch(
                  value: enabled,
                  onChanged: onChanged,
                  activeTrackColor: Colors.white.withValues(alpha: .3),
                  activeThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white.withValues(alpha: .2),
                  inactiveThumbColor: Colors.white,
                ),
            ],
          ),
          // ── 底部操作 ──
          if (!roleHeld) ...[
            const SizedBox(height: Spacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onEnable,
                icon: const Icon(Icons.verified_user_outlined, size: 18),
                label: const Text('立即开启系统权限'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.white.withValues(alpha: .5), blurRadius: 6),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 统计卡 ── 大数字优先，图标徽章克制
// ══════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(Spacing.base),
      child: Row(
        children: [
          LeadingBadge(icon: icon, color: color, size: 36, iconSize: 18),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 12, color: T.inkMuted)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ══════════════════════════════════════════════
// 策略行 ── LeadingBadge + 标签 + 药丸
// ══════════════════════════════════════════════
class _PolicyRow extends StatelessWidget {
  const _PolicyRow({required this.category, required this.subtitle, required this.blocked});
  final CallCategory category;
  final String subtitle;
  final bool blocked;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        LeadingBadge(icon: category.icon, color: category.color),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 1),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: T.inkMuted)),
            ],
          ),
        ),
        StatusPill(label: blocked ? '拦截' : '放行', color: blocked ? T.danger : T.success),
      ],
    ),
  );
}

// ══════════════════════════════════════════════
// 来电记录行 ── LeadingBadge + 号码 + 类别 + 药丸/时间
// ══════════════════════════════════════════════
class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.onDial});
  final CallRecord record;
  final ValueChanged<CallRecord> onDial;

  @override
  Widget build(BuildContext context) {
    final color = switch (record.action) {
      CallAction.block => T.danger,
      CallAction.silence => T.warning,
      CallAction.allow => T.success,
    };
    final icon = switch (record.action) {
      CallAction.block => Icons.block_rounded,
      CallAction.silence => Icons.notifications_off_rounded,
      CallAction.allow => Icons.call_rounded,
    };
    final label = switch (record.action) {
      CallAction.block => '已拦截',
      CallAction.silence => '已静音',
      CallAction.allow => '已放行',
    };
    final canDial = _canDialRecord(record);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: 4),
      leading: LeadingBadge(icon: icon, color: color),
      title: Text(record.number),
      subtitle: Text(record.category.label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canDial)
            IconButton(
              tooltip: '回拨 ${record.number}',
              icon: const Icon(Icons.phone_callback_rounded),
              color: T.brand,
              onPressed: () => onDial(record),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusPill(label: label, color: color),
              const SizedBox(height: 3),
              Text(
                _fmt(record.timestamp),
                style: const TextStyle(fontSize: 11, color: T.inkSubtle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime v) {
    final now = DateTime.now();
    final hh = v.hour.toString().padLeft(2, '0');
    final mm = v.minute.toString().padLeft(2, '0');
    if (v.year == now.year && v.month == now.month && v.day == now.day) return '$hh:$mm';
    return '${v.month}/${v.day}';
  }

  static bool _canDialRecord(CallRecord record) =>
      record.action != CallAction.allow && RegExp(r'\d').hasMatch(record.number);
}
