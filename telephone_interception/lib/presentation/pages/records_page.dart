import 'package:flutter/material.dart';

import '../../domain/models/call_action.dart';
import '../../domain/models/call_record.dart';
import '../widgets/common_widgets.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({
    super.key,
    required this.records,
    required this.onRefresh,
    required this.onClear,
  });
  final List<CallRecord> records;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.history,
                title: '暂无筛选记录',
                subtitle: '系统筛选来电后会显示在这里',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _confirmClear(context),
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('清空记录'),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = records[index];
                final stateColor = switch (record.action) {
                  CallAction.block => Colors.red,
                  CallAction.silence => Colors.orange,
                  CallAction.allow => Colors.green,
                };
                final stateIcon = switch (record.action) {
                  CallAction.block => Icons.call_end,
                  CallAction.silence => Icons.notifications_off_outlined,
                  CallAction.allow => Icons.call,
                };
                final stateLabel = switch (record.action) {
                  CallAction.block => '已拦截',
                  CallAction.silence => '已静音',
                  CallAction.allow => '已放行',
                };
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: stateColor.withValues(alpha: .1),
                      child: Icon(stateIcon, color: stateColor),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.number,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          _formatTime(record.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${record.category.label} · $stateLabel\n${record.reason}',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空来电记录？'),
        content: const Text('号码规则不会受到影响。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (clear == true) await onClear();
  }

  static String _formatTime(DateTime value) {
    final now = DateTime.now();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    if (value.year == now.year &&
        value.month == now.month &&
        value.day == now.day) {
      return '今天 $hour:$minute';
    }
    return '${value.month}月${value.day}日 $hour:$minute';
  }
}
