import 'package:flutter/material.dart';

import '../../domain/models/call_category.dart';
import '../../domain/models/screening_settings.dart';
import '../widgets/common_widgets.dart';

class NumbersPage extends StatelessWidget {
  const NumbersPage({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final ScreeningSettings settings;
  final ValueChanged<ScreeningSettings> onChanged;

  Future<void> _openPrefixDetails(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _PrefixRulesPage(
          initialPrefixes: settings.blockedPrefixes,
          onChanged: (prefixes) =>
              onChanged(settings.copyWith(blockedPrefixes: prefixes)),
        ),
      ),
    );
  }

  Future<void> _openNumberDetails(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            _NumberRulesPage(initialSettings: settings, onChanged: onChanged),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefixes = settings.blockedPrefixes.toList()..sort();
    final entries = <_NumberEntry>[
      ...settings.blacklist.map(
        (number) => _NumberEntry(number, CallCategory.blacklist),
      ),
      ...settings.whitelist.map(
        (number) => _NumberEntry(number, CallCategory.whitelist),
      ),
      ...settings.labels.entries.map(
        (item) => _NumberEntry(item.key, item.value),
      ),
    ]..sort((left, right) => left.number.compareTo(right.number));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        const NoticeCard(
          icon: Icons.info_outline,
          text: '白名单优先于号段规则。建议至少输入 3 位号段，号段越短，误拦风险越高。',
        ),
        const SizedBox(height: 14),
        Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openPrefixDetails(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.filter_alt_off_outlined),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '号段拦截',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text('点击查看和管理全部规则'),
                          ],
                        ),
                      ),
                      Text(
                        '共 ${prefixes.length} 个',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (prefixes.isEmpty)
                    const Text('暂无规则，例如添加 170 后将拦截所有 170 开头的号码。')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: prefixes
                          .take(4)
                          .map(
                            (prefix) => Chip(
                              avatar: const Icon(Icons.block, size: 17),
                              label: Text('$prefix*'),
                            ),
                          )
                          .toList(),
                    ),
                  if (prefixes.length > 4)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('还有 ${prefixes.length - 4} 个号段未显示'),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openNumberDetails(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.contact_phone_outlined),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '单个号码',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text('点击查看和管理全部规则'),
                          ],
                        ),
                      ),
                      Text(
                        '共 ${entries.length} 个',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (entries.isEmpty)
                    const Text('暂无规则，可添加黑白名单或标记号码分类。')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entries
                          .take(4)
                          .map(
                            (entry) => Chip(
                              avatar: Icon(entry.category.icon, size: 17),
                              label: Text(entry.number),
                            ),
                          )
                          .toList(),
                    ),
                  if (entries.length > 4)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('还有 ${entries.length - 4} 个号码未显示'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberRulesPage extends StatefulWidget {
  const _NumberRulesPage({
    required this.initialSettings,
    required this.onChanged,
  });

  final ScreeningSettings initialSettings;
  final ValueChanged<ScreeningSettings> onChanged;

  @override
  State<_NumberRulesPage> createState() => _NumberRulesPageState();
}

class _NumberRulesPageState extends State<_NumberRulesPage> {
  late final Set<String> blacklist = {...widget.initialSettings.blacklist};
  late final Set<String> whitelist = {...widget.initialSettings.whitelist};
  late final Map<String, CallCategory> labels = {
    ...widget.initialSettings.labels,
  };

  List<_NumberEntry> get entries => <_NumberEntry>[
    ...blacklist.map((number) => _NumberEntry(number, CallCategory.blacklist)),
    ...whitelist.map((number) => _NumberEntry(number, CallCategory.whitelist)),
    ...labels.entries.map((item) => _NumberEntry(item.key, item.value)),
  ]..sort((left, right) => left.number.compareTo(right.number));

  Future<void> _add() async {
    final entry = await showDialog<_NumberEntry>(
      context: context,
      builder: (_) => const _AddNumberDialog(),
    );
    if (entry == null) return;
    if (!mounted) return;
    final confirmed = await showActionConfirmation(
      context,
      title: '确认添加号码？',
      message: '${entry.number}\n处理方式：${entry.category.label}',
      confirmLabel: '确认添加',
    );
    if (!confirmed || !mounted) return;

    setState(() {
      blacklist.remove(entry.number);
      whitelist.remove(entry.number);
      labels.remove(entry.number);
      switch (entry.category) {
        case CallCategory.blacklist:
          blacklist.add(entry.number);
        case CallCategory.whitelist:
          whitelist.add(entry.number);
        default:
          labels[entry.number] = entry.category;
      }
    });
    _notifyChanged();
  }

  Future<void> _remove(_NumberEntry entry) async {
    final confirmed = await showActionConfirmation(
      context,
      title: '确认删除号码？',
      message: '删除 ${entry.number} 的“${entry.category.label}”规则后，该号码将不再按此规则处理。',
      confirmLabel: '确认删除',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      blacklist.remove(entry.number);
      whitelist.remove(entry.number);
      labels.remove(entry.number);
    });
    _notifyChanged();
  }

  void _notifyChanged() {
    widget.onChanged(
      widget.initialSettings.copyWith(
        blacklist: blacklist,
        whitelist: whitelist,
        labels: labels,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEntries = entries;
    return Scaffold(
      appBar: AppBar(
        title: Text('单个号码（${currentEntries.length}）'),
        actions: [
          IconButton(
            tooltip: '添加号码',
            onPressed: _add,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: currentEntries.isEmpty
          ? Column(
              children: [
                const Expanded(
                  child: EmptyState(
                    icon: Icons.contact_phone_outlined,
                    title: '暂无号码规则',
                    subtitle: '添加黑白名单，或给已知号码标记分类',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _add,
                      icon: const Icon(Icons.add),
                      label: const Text('添加号码'),
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: currentEntries.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const NoticeCard(
                    icon: Icons.rule,
                    text: '白名单始终优先放行，黑名单始终拦截；分类号码按照“拦截规则”页的开关处理。',
                  );
                }
                final entry = currentEntries[index - 1];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: entry.category.color.withValues(
                        alpha: .12,
                      ),
                      foregroundColor: entry.category.color,
                      child: Icon(entry.category.icon),
                    ),
                    title: Text(
                      entry.number,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(entry.category.label),
                    trailing: IconButton(
                      tooltip: '删除 ${entry.number}',
                      onPressed: () => _remove(entry),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: currentEntries.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text('添加号码'),
            ),
    );
  }
}

class _PrefixRulesPage extends StatefulWidget {
  const _PrefixRulesPage({
    required this.initialPrefixes,
    required this.onChanged,
  });

  final Set<String> initialPrefixes;
  final ValueChanged<Set<String>> onChanged;

  @override
  State<_PrefixRulesPage> createState() => _PrefixRulesPageState();
}

class _PrefixRulesPageState extends State<_PrefixRulesPage> {
  late final Set<String> prefixes = {...widget.initialPrefixes};

  Future<void> _add() async {
    final prefix = await showDialog<String>(
      context: context,
      builder: (_) => const _AddPrefixDialog(),
    );
    if (prefix == null || prefixes.contains(prefix)) return;
    if (!mounted) return;
    final confirmed = await showActionConfirmation(
      context,
      title: '确认添加号段？',
      message: '添加 $prefix* 后，所有以 $prefix 开头且不在白名单中的号码都会被拦截。',
      confirmLabel: '确认添加',
    );
    if (!confirmed || !mounted) return;
    setState(() => prefixes.add(prefix));
    widget.onChanged(Set.unmodifiable(prefixes));
  }

  Future<void> _remove(String prefix) async {
    final confirmed = await showActionConfirmation(
      context,
      title: '确认删除号段？',
      message: '删除 $prefix* 后，该号段的来电将不再按此规则拦截。',
      confirmLabel: '确认删除',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => prefixes.remove(prefix));
    widget.onChanged(Set.unmodifiable(prefixes));
  }

  @override
  Widget build(BuildContext context) {
    final sortedPrefixes = prefixes.toList()..sort();
    return Scaffold(
      appBar: AppBar(
        title: Text('号段拦截（${prefixes.length}）'),
        actions: [
          IconButton(
            tooltip: '添加号段',
            onPressed: _add,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: sortedPrefixes.isEmpty
          ? Column(
              children: [
                const Expanded(
                  child: EmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: '暂无号段规则',
                    subtitle: '添加号码前缀，批量拦截该号段的来电',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _add,
                      icon: const Icon(Icons.add),
                      label: const Text('添加号段'),
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
              itemCount: sortedPrefixes.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const NoticeCard(
                    icon: Icons.info_outline,
                    text: '白名单优先级更高。号段以星号表示，例如 170* 会匹配所有 170 开头的号码。',
                  );
                }
                final prefix = sortedPrefixes[index - 1];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.filter_alt_off_outlined),
                    ),
                    title: Text(
                      '$prefix*',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('拦截所有 $prefix 开头的来电'),
                    trailing: IconButton(
                      tooltip: '删除 $prefix',
                      onPressed: () => _remove(prefix),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: sortedPrefixes.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text('添加号段'),
            ),
    );
  }
}

class _AddPrefixDialog extends StatefulWidget {
  const _AddPrefixDialog();

  @override
  State<_AddPrefixDialog> createState() => _AddPrefixDialogState();
}

class _AddPrefixDialogState extends State<_AddPrefixDialog> {
  final controller = TextEditingController();
  String? errorText;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('添加拦截号段'),
    content: TextField(
      controller: controller,
      autofocus: true,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: '号码开头',
        hintText: '例如 170 或 950',
        helperText: '所有以该号段开头的电话都会被拦截',
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: _submit, child: const Text('保存')),
    ],
  );

  void _submit() {
    final prefix = _normalizePrefix(controller.text);
    if (prefix.length < 3) {
      setState(() => errorText = '请至少输入 3 位数字');
      return;
    }
    Navigator.pop(context, prefix);
  }

  static String _normalizePrefix(String raw) {
    var value = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.startsWith('0086')) value = value.substring(4);
    if (raw.trim().startsWith('+86') && value.startsWith('86')) {
      value = value.substring(2);
    }
    return value;
  }
}

class _AddNumberDialog extends StatefulWidget {
  const _AddNumberDialog();

  @override
  State<_AddNumberDialog> createState() => _AddNumberDialogState();
}

class _AddNumberDialogState extends State<_AddNumberDialog> {
  final controller = TextEditingController();
  CallCategory category = CallCategory.blacklist;

  static const selectableCategories = [
    CallCategory.blacklist,
    CallCategory.whitelist,
    CallCategory.fraud,
    CallCategory.marketing,
    CallCategory.bank,
    CallCategory.carrier,
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('添加号码规则'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: '电话号码',
            hintText: '例如 10086',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CallCategory>(
          initialValue: category,
          decoration: const InputDecoration(
            labelText: '处理方式 / 分类',
            border: OutlineInputBorder(),
          ),
          items: selectableCategories
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(_optionLabel(item)),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => category = value ?? category),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: _submit, child: const Text('保存')),
    ],
  );

  void _submit() {
    final number = controller.text.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    if (number.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效号码')));
      return;
    }
    Navigator.pop(context, _NumberEntry(number, category));
  }

  static String _optionLabel(CallCategory item) => switch (item) {
    CallCategory.blacklist => '黑名单 · 始终拦截',
    CallCategory.whitelist => '白名单 · 始终放行',
    _ => '标记为${item.label}',
  };
}

class _NumberEntry {
  const _NumberEntry(this.number, this.category);
  final String number;
  final CallCategory category;
}
