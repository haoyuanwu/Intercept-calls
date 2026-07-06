import 'package:flutter/material.dart';

import '../../domain/models/call_action.dart';
import '../../domain/models/call_record.dart';
import '../../domain/models/screening_settings.dart';
import '../../domain/models/screening_status.dart';
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
  });

  final ScreeningStatus status;
  final ScreeningSettings settings;
  final List<CallRecord> records;
  final VoidCallback onEnable;
  final ValueChanged<ScreeningSettings> onSettingsChanged;
  final VoidCallback onOpenRecords;

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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: active
                  ? const [Color(0xFF176B5B), Color(0xFF238B72)]
                  : const [Color(0xFF626B69), Color(0xFF808986)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Icon(
                active ? Icons.shield_rounded : Icons.shield_outlined,
                color: Colors.white,
                size: 70,
              ),
              const SizedBox(height: 12),
              Text(
                active ? '来电防护中' : '防护尚未生效',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                status.roleHeld ? '规则已在本机生效，数据不会上传' : '需要设为系统来电筛选应用',
                style: const TextStyle(color: Color(0xFFE4F3EE)),
              ),
              const SizedBox(height: 18),
              if (!status.roleHeld)
                FilledButton.tonalIcon(
                  onPressed: onEnable,
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('立即开启系统权限'),
                )
              else
                SwitchListTile(
                  value: settings.enabled,
                  onChanged: (value) =>
                      onSettingsChanged(settings.copyWith(enabled: value)),
                  title: const Text(
                    '总防护开关',
                    style: TextStyle(color: Colors.white),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '$blockedToday',
                label: '今日已拦截',
                icon: Icons.block,
                color: const Color(0xFFD94A4A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                value: '${records.length}',
                label: '筛选记录',
                icon: Icons.call,
                color: const Color(0xFF176B5B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前策略',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _PolicyLine(text: '疑似诈骗', blocked: settings.blockFraud),
                _PolicyLine(text: '营销推广', blocked: settings.blockMarketing),
                _PolicyLine(text: '银行客服', blocked: settings.blockBank),
                _PolicyLine(text: '运营商客服', blocked: settings.blockCarrier),
              ],
            ),
          ),
        ),
        // const SizedBox(height: 14),
        // const NoticeCard(
        //   icon: Icons.info_outline,
        //   text: '未标记号码默认放行。号码库可以在仓库层接入，不会影响页面和原生拦截服务。',
        // ),
        // const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                '最近来电',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (records.isNotEmpty)
              TextButton(
                onPressed: onOpenRecords,
                child: Text('查看全部 ${records.length}'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (records.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: EmptyState(
                icon: Icons.history,
                title: '暂无筛选记录',
                subtitle: '系统筛选来电后会显示在这里',
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < records.take(5).length;
                  index++
                ) ...[
                  _RecentRecordTile(record: records[index]),
                  if (index != records.take(5).length - 1)
                    const Divider(height: 1, indent: 68),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _RecentRecordTile extends StatelessWidget {
  const _RecentRecordTile({required this.record});
  final CallRecord record;

  @override
  Widget build(BuildContext context) {
    final color = switch (record.action) {
      CallAction.block => Colors.red,
      CallAction.silence => Colors.orange,
      CallAction.allow => Colors.green,
    };
    final icon = switch (record.action) {
      CallAction.block => Icons.call_end,
      CallAction.silence => Icons.notifications_off_outlined,
      CallAction.allow => Icons.call,
    };
    final label = switch (record.action) {
      CallAction.block => '已拦截',
      CallAction.silence => '已静音',
      CallAction.allow => '已放行',
    };
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: .1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        record.number,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${record.category.label} · $label'),
      trailing: Text(_formatRecordTime(record.timestamp)),
    );
  }

  static String _formatRecordTime(DateTime value) {
    final now = DateTime.now();
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    if (value.year == now.year &&
        value.month == now.month &&
        value.day == now.day) {
      return time;
    }
    return '${value.month}/${value.day}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .1),
            foregroundColor: color,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(label),
            ],
          ),
        ],
      ),
    ),
  );
}

class _PolicyLine extends StatelessWidget {
  const _PolicyLine({required this.text, required this.blocked});
  final String text;
  final bool blocked;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(child: Text(text)),
        Text(
          blocked ? '拦截' : '放行',
          style: TextStyle(
            color: blocked ? Colors.red.shade700 : Colors.green.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
