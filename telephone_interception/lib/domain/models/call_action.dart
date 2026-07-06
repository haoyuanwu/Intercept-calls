enum CallAction {
  allow('allow'),
  silence('silence'),
  block('block');

  const CallAction(this.wireName);
  final String wireName;

  static CallAction fromWire(String? value, {bool legacyBlocked = false}) =>
      values.firstWhere(
        (item) => item.wireName == value,
        orElse: () => legacyBlocked ? CallAction.block : CallAction.allow,
      );
}
