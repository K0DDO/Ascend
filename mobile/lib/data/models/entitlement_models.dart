class EntitlementItem {
  const EntitlementItem({
    required this.key,
    required this.constraints,
    this.endsAt,
  });

  final String key;
  final Map<String, dynamic> constraints;
  final DateTime? endsAt;

  factory EntitlementItem.fromJson(Map<String, dynamic> json) {
    return EntitlementItem(
      key: json['key'] as String,
      constraints: json['constraints'] as Map<String, dynamic>? ?? const {},
      endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'] as String) : null,
    );
  }
}
