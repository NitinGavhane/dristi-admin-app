import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../widgets.dart';

class DeliverySettingsScreen extends StatefulWidget {
  const DeliverySettingsScreen({super.key});

  @override
  State<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends State<DeliverySettingsScreen> {
  final AdminService _admin = AdminService(ApiService());
  final _feeCtrl = TextEditingController();
  final _freeAboveCtrl = TextEditingController();
  bool _enabled = false;
  bool _loading = true, _saving = false;

  @override
  void initState() {
    super.initState();
    void refresh() {
      // Typing a fee is intent to charge delivery — flip the toggle on so the
      // seller isn't left wondering why the app still shows FREE.
      if ((double.tryParse(_feeCtrl.text.trim()) ?? 0.0) > 0) _enabled = true;
      if (mounted) setState(() {});
    }
    _feeCtrl.addListener(refresh);
    _freeAboveCtrl.addListener(refresh);
    _load();
  }

  @override
  void dispose() {
    _feeCtrl.dispose();
    _freeAboveCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final s = await _admin.getDeliverySettings();
      _enabled = s.enabled;
      if (s.fee > 0) _feeCtrl.text = _trim(s.fee);
      if (s.freeAbove != null) _freeAboveCtrl.text = _trim(s.freeAbove!);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  String _trim(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 2);

  Future<void> _save() async {
    setState(() => _saving = true);
    final fee = double.tryParse(_feeCtrl.text.trim()) ?? 0.0;
    final freeAboveText = _freeAboveCtrl.text.trim();
    final freeAbove = freeAboveText.isEmpty ? null : double.tryParse(freeAboveText);
    try {
      await _admin.updateDeliverySettings({
        'enabled': fee > 0 ? true : _enabled,
        'fee': fee,
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
    if (!_enabled || fee <= 0) {
      return 'Delivery is FREE on every order.';
    }
    if (freeAbove != null && freeAbove > 0) {
      return 'Delivery costs ₹${_trim(fee)}, and is FREE when the order subtotal reaches ₹${_trim(freeAbove)}.';
    }
    return 'Delivery costs ₹${_trim(fee)} on every order.';
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
                      StyledInput(controller: _feeCtrl, label: 'Delivery Fee (₹)', number: true, hint: 'e.g. 50'),
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
