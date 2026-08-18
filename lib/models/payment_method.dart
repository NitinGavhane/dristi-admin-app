/// A payment method offered at checkout.
///
/// `gateway` is which provider settles it and `regions` where it is offered —
/// both are admin configuration and never shown to buyers.
class AdminPaymentMethod {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String? iconUrl;
  final String gateway;
  final String regions;
  final bool isActive;
  final int sortOrder;

  const AdminPaymentMethod({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.iconUrl,
    this.gateway = 'cashfree',
    this.regions = '*',
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory AdminPaymentMethod.fromJson(Map<String, dynamic> json) {
    return AdminPaymentMethod(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      gateway: (json['gateway'] as String?) ?? 'cashfree',
      regions: (json['regions'] as String?) ?? '*',
      isActive: (json['is_active'] as bool?) ?? true,
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }

  /// Human-readable regions for the list view.
  String get regionsLabel => regions.trim() == '*' ? 'ALL REGIONS' : regions.toUpperCase();

  /// Gateways the Admin app can pick from. Cashfree is wired up today; the
  /// field exists so adding a second one is configuration, not a schema change.
  static const List<String> gatewayOptions = ['cashfree'];
}
