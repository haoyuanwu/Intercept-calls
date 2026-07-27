import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/official_numbers/official_number_catalog.dart';
import '../../domain/models/official_number.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';

class OfficialNumbersPage extends StatefulWidget {
  const OfficialNumbersPage({super.key});

  @override
  State<OfficialNumbersPage> createState() => _OfficialNumbersPageState();
}

class _OfficialNumbersPageState extends State<OfficialNumbersPage> {
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  OfficialNumberCategory? selectedCategory;
  String query = '';
  bool searchVisible = false;

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = officialNumberCatalog.where((item) {
      if (selectedCategory != null && item.category != selectedCategory) return false;
      final keyword = query.trim().toLowerCase();
      return keyword.isEmpty ||
          item.organization.toLowerCase().contains(keyword) ||
          item.number.contains(keyword) ||
          item.description.toLowerCase().contains(keyword);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, Spacing.xl),
      children: [
        const NoticeCard(
          icon: Icons.verified_user_outlined,
          text: '以下为公开服务热线。来电号码可能被伪造，涉及转账、验证码或账户信息时，请复制号码后主动回拨核实。',
        ),
        const SizedBox(height: Spacing.md),
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryChip(
                      label: '全部 ${officialNumberCatalog.length}',
                      selected: selectedCategory == null,
                      onSelected: () => setState(() => selectedCategory = null),
                    ),
                    ...OfficialNumberCategory.values.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(left: Spacing.sm),
                        child: _CategoryChip(
                          label: '${category.label} ${officialNumberCatalog.where((item) => item.category == category).length}',
                          selected: selectedCategory == category,
                          onSelected: () => setState(() => selectedCategory = category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            IconButton.filledTonal(
              tooltip: searchVisible ? '收起搜索' : '搜索平台号码',
              onPressed: _toggleSearch,
              icon: AnimatedRotation(
                turns: searchVisible ? .25 : 0,
                duration: const Duration(milliseconds: 220),
                child: Icon(searchVisible ? Icons.close_rounded : Icons.search_rounded),
              ),
            ),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          reverseDuration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(sizeFactor: animation, alignment: Alignment.topCenter, child: child),
          ),
          child: searchVisible
              ? Padding(
                  key: const ValueKey('search-field'),
                  padding: const EdgeInsets.only(top: Spacing.md),
                  child: SearchBar(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    autoFocus: true,
                    hintText: '搜索机构名称或电话号码',
                    elevation: const WidgetStatePropertyAll(0),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    leading: const Icon(Icons.search_rounded),
                    trailing: [
                      if (query.isNotEmpty)
                        IconButton(
                          tooltip: '清空搜索',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.backspace_outlined),
                        ),
                    ],
                    onChanged: (value) => setState(() => query = value),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('search-hidden')),
        ),
        const SizedBox(height: Spacing.md),
        if (results.isEmpty)
          const SizedBox(
            height: 320,
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: '没有找到号码',
              subtitle: '请尝试搜索机构简称或电话号码',
            ),
          )
        else
          ..._buildGroupedResults(results),
      ],
    );
  }

  void _toggleSearch() {
    if (searchVisible) {
      searchFocusNode.unfocus();
      searchController.clear();
      setState(() {
        searchVisible = false;
        query = '';
      });
      return;
    }
    setState(() => searchVisible = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) searchFocusNode.requestFocus();
    });
  }

  void _clearSearch() {
    searchController.clear();
    setState(() => query = '');
    searchFocusNode.requestFocus();
  }

  List<Widget> _buildGroupedResults(List<OfficialNumber> results) {
    final categories = selectedCategory == null
        ? OfficialNumberCategory.values
        : [selectedCategory!];
    return categories.expand((category) {
      final items = results.where((item) => item.category == category).toList();
      if (items.isEmpty) return const <Widget>[];
      return <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(2, Spacing.sm, 2, Spacing.sm),
          child: Row(
            children: [
              Icon(category.icon, size: 18, color: category.color),
              const SizedBox(width: Spacing.sm),
              Text(
                '${category.label} · ${items.length}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _OfficialNumberTile(item: items[i], onCopy: _copy),
                if (i != items.length - 1)
                  const Divider(height: 1, indent: 64),
              ],
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
      ];
    }).toList();
  }

  Future<void> _copy(OfficialNumber item) async {
    await Clipboard.setData(ClipboardData(text: item.number));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('已复制 ${item.organization}：${item.number}')));
  }
}

class _OfficialNumberTile extends StatelessWidget {
  const _OfficialNumberTile({required this.item, required this.onCopy});
  final OfficialNumber item;
  final ValueChanged<OfficialNumber> onCopy;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.fromLTRB(Spacing.base, 3, Spacing.sm, 3),
    leading: LeadingBadge(icon: item.category.icon, color: item.category.color),
    title: Text(item.organization),
    subtitle: Text('${item.number} · ${item.description}'),
    trailing: IconButton(
      tooltip: '复制 ${item.number}',
      onPressed: () => onCopy(item),
      icon: const Icon(Icons.copy_outlined, color: T.inkSubtle),
    ),
    onTap: () => onCopy(item),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onSelected(),
  );
}

extension on OfficialNumberCategory {
  String get label => switch (this) {
    OfficialNumberCategory.bank => '银行',
    OfficialNumberCategory.carrier => '运营商',
    OfficialNumberCategory.government => '政府服务',
  };

  IconData get icon => switch (this) {
    OfficialNumberCategory.bank => Icons.account_balance_rounded,
    OfficialNumberCategory.carrier => Icons.cell_tower_rounded,
    OfficialNumberCategory.government => Icons.apartment_rounded,
  };

  Color get color => switch (this) {
    OfficialNumberCategory.bank => T.info,
    OfficialNumberCategory.carrier => T.brand,
    OfficialNumberCategory.government => const Color(0xFF7558A6),
  };
}
