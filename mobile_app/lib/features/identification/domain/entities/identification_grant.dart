class IdentificationGrant {
  final String token;
  final String type;
  final DateTime expiresAt;

  const IdentificationGrant({
    required this.token,
    required this.type,
    required this.expiresAt,
  });

  bool get isExpired => !expiresAt.isAfter(DateTime.now());
}
