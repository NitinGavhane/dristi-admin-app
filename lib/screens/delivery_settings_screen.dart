import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../widgets.dart';

// The Indian states & union territories a buyer can set as their delivery
// state. A fee entered here overrides the default for that destination; leaving
// one blank means that state pays the default fee.
const List<String> kIndiaStates = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chandigarh',
  'Chhattisgarh',
  'Dadra and Nagar Haveli and Daman and Diu',
  'Delhi',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jammu and Kashmir',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Ladakh',
  'Lakshadweep',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Puducherry',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
];

// Matches the backend's default per-state map (delivery priced by distance from
// the seller in West Bengal). Since billing only needs the best match, "Jammu &
// Kashmir" here also covers the "and" spelling on addresses.
const Map<String, double> kDefaultStateFees = {
  'West Bengal': 49,
  'Bihar': 49,
  'Jharkhand': 49,
  'Odisha': 49,
  'Sikkim': 49,
  'Assam': 59,
  'Arunachal Pradesh': 59,
  'Meghalaya': 59,
  'Manipur': 59,
  'Mizoram': 59,
  'Nagaland': 59,
  'Tripura': 59,
  'Chhattisgarh': 69,
  'Madhya Pradesh': 69,
  'Uttar Pradesh': 69,
  'Uttarakhand': 69,
  'Rajasthan': 79,
  'Delhi': 79,
  'Haryana': 79,
  'Punjab': 79,
  'Himachal Pradesh': 79,
  'Chandigarh': 79,
  'Jammu & Kashmir': 99,
  'Jammu and Kashmir': 99,
  'Ladakh': 99,
  'Maharashtra': 79,
  'Gujarat': 79,
  'Goa': 89,
  'Karnataka': 89,
  'Telangana': 89,
  'Andhra Pradesh': 89,
  'Tamil Nadu': 89,
  'Kerala': 89,
  'Puducherry': 89,
};

class DeliverySettingsScreen extends StatefulWidget {
  const DeliverySettingsScreen({super.key});

  @override
  State<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends State<DeliverySettingsScreen> {
  final AdminService _admin = AdminService(ApiService());
  final _feeCtrl = TextEditingController();
  final _freeAboveCtrl = TextEditingController();
  late final Map<String, TextEditingController> _stateCtrls;
  bool _enabled = false;
  bool _loading = true, _saving = false;
  Map<String, double> _stateFees = {};

  @override
  void initState() {
    super.initState();
    _stateCtrls = {
      for (final s in kIndiaStates) s: TextEditingController(),
    };
    void refresh() {
      // Typing a fee is intent to charge delivery — flip the toggle on so the
      // seller isn't left wondering why the storefront still shows FREE.
      if ((double.tryParse(_feeCtrl.text.trim()) ?? 0.0) > 0) _enabled = true;
      if (mounted) setState(() {});
    }
    _feeCtrl.addListener(refresh);
    _freeAboveCtrl.addListener(refresh);
    for (final c in _stateCtrls.values) {
      c.addListener(refresh);
    }
    _load();
  }

  @override
  void dispose() {
    _feeCtrl.dispose();
    _freeAboveCtrl.dispose();
    for (final c in _stateCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final s = await _admin.getDeliverySettings();
      _enabled = s.enabled;
      if (s.fee > 0) _feeCtrl.text = _trim(s.fee);
      if (s.freeAbove != null) _freeAboveCtrl.text = _trim(s.freeAbove!);
      // Merge server state fees on top of the defaults so any amount the admin
      // previously saved for a state (even 0 to force-free a route) survives.
      _stateFees = {...kDefaultStateFees, ...?s.stateFees};
      for (final entry in _stateFees.entries) {
        final ctrl = _stateCtrls[entry.key];
        if (ctrl != null && ctrl.text.isEmpty) ctrl.text = _trim(entry.value);
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  String _trim(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 2);

  Future<void> _save() async {
    setState(() => _saving = true);
    final fee = double.tryParse(_feeCtrl.text.trim()) ?? 0.0;
    final freeAboveText = _freeAboveCtrl.text.trim();
    final freeAbove = freeAboveText.isEmpty ? null : double.tryParse(freeAboveText);
    // Only non-blank states are written; blank ones fall back to the default.
    final stateFees = <String, double>{
      for (final entry in _stateCtrls.entries)
        if (entry.value.text.trim().isNotEmpty)
          entry.key: double.tryParse(entry.value.text.trim()) ?? 0.0,
    };
    try {
      await _admin.updateDeliverySettings({
        'enabled': fee > 0 ? true : _enabled,
        'fee': fee,
        'state_fees': stateFees,
        'free_above': freeAbove,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  /// Plain-language summary of what buyers will be charged, given the current
  /// (unsaved) field values.
  String get _rulePreview {
    final fee = double.tryParse(_feeCtrl.text.trim()) ?? 0.0;
    final freeAbove = double.tryParse(_freeAboveCtrl.text.trim());
    final explicitStates = _stateCtrls.entries
        .where((e) => e.value.text.trim().isNotEmpty)
        .length;
    if (!_enabled || fee <= 0) {
      return 'Delivery is FREE on every order.';
    }
    final freeNote = (freeAbove != null && freeAbove > 0)
        ? ' FREE when the order subtotal reaches ₹${_trim(freeAbove)}.'
        : '';
    if (explicitStates > 0) {
      return 'Delivery costs ₹${_trim(fee)} by default, with $explicitStates states priced separately by distance.'
          '$freeNote';
    }
    return 'Delivery costs ₹${_trim(fee)} on every order.$freeNote';
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/delivery-settings',
      body: Column(children: [
        Builder(builder: (ctx) => BrandHeader(
          title: 'Delivery',
          subtitle: 'CHARGE SETTINGS',
          onMenuTap: () => Scaffold.of(ctx).openDrawer(),
        )),
        Expanded(
          child: _loading
              ? const BrandLoader(label: 'Loading')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    FormSection(title: 'Delivery Charge', children: [
                      ToggleRow(
                        label: 'Charge for delivery',
                        value: _enabled,
                        onChanged: (v) => setState(() => _enabled = v),
                      ),
                      const SizedBox(height: 14),
                      StyledInput(controller: _feeCtrl, label: 'Default Delivery Fee (₹)', number: true, hint: 'e.g. 50 — used for any state not priced below'),
                      StyledInput(controller: _freeAboveCtrl, label: 'Free delivery above (₹)', number: true, hint: 'Optional — leave blank for none'),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.btnColor.withValues(alpha: 0.3), width: 1),
                          color: AppColors.btnColor.withValues(alpha: 0.05),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 16, color: AppColors.btnColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _rulePreview,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    FormSection(title: 'State-wise Charges (₹)', children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Set a delivery fee for each state. Leave a state blank to fall back to the default fee above. Delivery is charged by how far the parcel travels.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                        ),
                      ),
                      for (final state in kIndiaStates)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: StyledInput(
                            controller: _stateCtrls[state]!,
                            label: state,
                            number: true,
                            hint: 'Default ₹${_trim(_stateFees[state] ?? 0)}',
                          ),
                        ),
                    ]),
                    const SizedBox(height: 24),
                    FashionButton(
                      label: 'Save Settings',
                      loading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
        ),
      ]),
    );
  }
}