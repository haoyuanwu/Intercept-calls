import 'call_category.dart';

class ScreeningSettings {
  const ScreeningSettings({
    this.enabled = true,
    this.blockFraud = true,
    this.blockMarketing = true,
    this.blockPrivate = false,
    this.blockBank = false,
    this.blockCarrier = false,
    this.builtInRulesEnabled = true,
    this.repeatedCallProtection = true,
    this.blacklist = const {},
    this.whitelist = const {},
    this.blockedPrefixes = const {},
    this.labels = const {},
  });

  final bool enabled;
  final bool blockFraud;
  final bool blockMarketing;
  final bool blockPrivate;
  final bool blockBank;
  final bool blockCarrier;
  final bool builtInRulesEnabled;
  final bool repeatedCallProtection;
  final Set<String> blacklist;
  final Set<String> whitelist;
  final Set<String> blockedPrefixes;
  final Map<String, CallCategory> labels;

  ScreeningSettings copyWith({
    bool? enabled,
    bool? blockFraud,
    bool? blockMarketing,
    bool? blockPrivate,
    bool? blockBank,
    bool? blockCarrier,
    bool? builtInRulesEnabled,
    bool? repeatedCallProtection,
    Set<String>? blacklist,
    Set<String>? whitelist,
    Set<String>? blockedPrefixes,
    Map<String, CallCategory>? labels,
  }) => ScreeningSettings(
    enabled: enabled ?? this.enabled,
    blockFraud: blockFraud ?? this.blockFraud,
    blockMarketing: blockMarketing ?? this.blockMarketing,
    blockPrivate: blockPrivate ?? this.blockPrivate,
    blockBank: blockBank ?? this.blockBank,
    blockCarrier: blockCarrier ?? this.blockCarrier,
    builtInRulesEnabled: builtInRulesEnabled ?? this.builtInRulesEnabled,
    repeatedCallProtection:
        repeatedCallProtection ?? this.repeatedCallProtection,
    blacklist: Set.unmodifiable(blacklist ?? this.blacklist),
    whitelist: Set.unmodifiable(whitelist ?? this.whitelist),
    blockedPrefixes: Set.unmodifiable(blockedPrefixes ?? this.blockedPrefixes),
    labels: Map.unmodifiable(labels ?? this.labels),
  );
}
