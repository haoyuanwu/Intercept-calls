enum OfficialNumberCategory { bank, carrier, government }

class OfficialNumber {
  const OfficialNumber({
    required this.organization,
    required this.number,
    required this.category,
    required this.description,
  });

  final String organization;
  final String number;
  final OfficialNumberCategory category;
  final String description;
}
