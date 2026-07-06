enum CallCategory {
  normal('normal'),
  privateNumber('private'),
  whitelist('whitelist'),
  blacklist('blacklist'),
  blockedPrefix('prefix'),
  graylist('graylist'),
  fraud('fraud'),
  marketing('marketing'),
  bank('bank'),
  carrier('carrier');

  const CallCategory(this.wireName);
  final String wireName;

  static CallCategory fromWire(String? value) => values.firstWhere(
    (item) => item.wireName == value,
    orElse: () => CallCategory.normal,
  );
}
