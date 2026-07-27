import 'package:flutter/material.dart';

import '../../domain/models/call_action.dart';
import '../../domain/models/call_record.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({
    super.key,
    required this.records,
    required this.onRefresh,
    required this.onDialRecord,
  });
  final List<CallRecord> records;
  final Future<void> Function() onRefresh;
  final ValueChanged<CallRecord> onDialRecord;

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  CallAction? _filter;

  List<CallRecord> get _filtered => _filter == null
      ? widget.records
      : widget.records.where((r) => r.action == _filter).toList();

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.history_rounded,
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
        _FilterBar(
          records: widget.records,
          selected: _filter,
          onSelected: (v) => setState(() => _filter = v),
        ),
        if (_filtered.isEmpty)
          const Expanded(
            child: EmptyState(
              icon: Icons.filter_list_off_rounded,
              title: '无匹配记录',
              subtitle: '当前筛选条件下没有记录',
            ),
          )
        else ...[
          // ── 条数提示 ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.xs,
            ),
            child: Text(
              '共 ${_filtered.length} 条记录',
              style: const TextStyle(fontSize: 12, color: T.inkSubtle),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.base, 0, Spacing.base, Spacing.base,
                ),
                itemCount: _filtered.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: Spacing.sm),
                itemBuilder: (_, i) => _RecordItem(
                  record: _filtered[i],
                  onDial: widget.onDialRecord,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// 筛选栏 — 横滑 FilterChip
// ─────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.records,
    required this.selected,
    required this.onSelected,
  });
  final List<CallRecord> records;
  final CallAction? selected;
  final ValueChanged<CallAction?> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <_FilterOption>[
      _FilterOption(null, '全部', T.inkMuted, Icons.inbox_rounded),
      _FilterOption(CallAction.block, '已拦截', T.danger, Icons.block_rounded),
      _FilterOption(
        CallAction.silence, '已静音', T.warning, Icons.notifications_off_rounded,
      ),
      _FilterOption(CallAction.allow, '已放行', T.success, Icons.call_rounded),
    ];

    // 预计算各筛选项的命中数
    final counts = <CallAction?, int>{};
    for (final opt in items) {
      counts[opt.action] = opt.action == null
          ? records.length
          : records.where((r) => r.action == opt.action).length;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: items.map((opt) {
          final active = selected == opt.action;
          final n = counts[opt.action] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(right: Spacing.sm),
            child: FilterChip(
              selected: active,
              onSelected: (_) => onSelected(opt.action),
              label: Text('${opt.label} $n'),
              avatar: Icon(
                opt.icon,
                size: 16,
                color: active ? Colors.white : opt.color,
              ),
              selectedColor: opt.color,
              showCheckmark: false,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : T.ink,
              ),
              side: active
                  ? BorderSide.none
                  : const BorderSide(color: T.hairline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusT.pill),
              ),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterOption {
  const _FilterOption(this.action, this.label, this.color, this.icon);
  final CallAction? action;
  final String label;
  final Color color;
  final IconData icon;
}

// ─────────────────────────────────────────────
// 列表项 — 类别徽章 + 号码/原因 + 时间/状态
// ─────────────────────────────────────────────
class _RecordItem extends StatelessWidget {
  const _RecordItem({required this.record, required this.onDial});
  final CallRecord record;
  final ValueChanged<CallRecord> onDial;

  @override
  Widget build(BuildContext context) {
    final color = switch (record.action) {
      CallAction.block => T.danger,
      CallAction.silence => T.warning,
      CallAction.allow => T.success,
    };
    final label = switch (record.action) {
      CallAction.block => '已拦截',
      CallAction.silence => '已静音',
      CallAction.allow => '已放行',
    };
    final canDial = _canDialRecord(record);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          children: [
            // 左侧：来电类别图标徽章（比动作图标信息量更大）
            LeadingBadge(
              icon: record.category.icon,
              color: record.category.color,
            ),
            const SizedBox(width: Spacing.md),
            // 中间：号码 + 原因
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.number,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: T.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        record.category.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: T.inkMuted,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: T.inkSubtle,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          record.reason,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: T.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            // 右侧：回拨 + 时间 + 操作状态药丸
            Row(
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _fmt(record.timestamp),
                      style: const TextStyle(fontSize: 11, color: T.inkSubtle),
                    ),
                    const SizedBox(height: 6),
                    StatusPill(label: label, color: color),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(DateTime v) {
    final now = DateTime.now();
    final hh = v.hour.toString().padLeft(2, '0');
    final mm = v.minute.toString().padLeft(2, '0');
    if (v.year == now.year &&
        v.month == now.month &&
        v.day == now.day) {
      return '今天 $hh:$mm';
    }
    return '${v.month}月${v.day}日 $hh:$mm';
  }

  static bool _canDialRecord(CallRecord record) =>
      record.action != CallAction.allow && RegExp(r'\d').hasMatch(record.number);
}
