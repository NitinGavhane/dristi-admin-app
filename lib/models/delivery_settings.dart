class DeliverySettings {
  final bool enabled;
  final double fee;
  final Map<String, double>? stateFees;
  final double? freeAbove;

  const DeliverySettings({
    this.enabled = false,
    this.fee = 0.0,
    this.stateFees,
    this.freeAbove,
  });

  factory DeliverySettings.fromJson(Map<String, dynamic> json) {
    final rawFees = json['state_fees'];
    Map<String, double>? fees;
    if (rawFees is Map<String, dynamic>) {
      fees = rawFees.map((k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0.0));
    }
    return DeliverySettings(
      enabled: json['enabled'] as bool? ?? false,
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      stateFees: fees,
      freeAbove: (json['free_above'] as num?)?.toDouble(),
    );
  }
}