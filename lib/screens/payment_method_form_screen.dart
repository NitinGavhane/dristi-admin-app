import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/payment_method.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../widgets.dart';

class PaymentMethodFormScreen extends StatefulWidget {
  const PaymentMethodFormScreen({super.key});

  @override
  State<PaymentMethodFormScreen> createState() => _PaymentMethodFormScreenState();
}

class _PaymentMethodFormScreenState extends State<PaymentMethodFormScreen> {
  final AdminService _admin = AdminService(ApiService());
  final _fk = GlobalKey<FormState>();
  final _codeC = TextEditingController();
  final _nameC = TextEditingController();
  final _descC = TextEditingController();
  final _iconC = TextEditingController();
  final _regionsC = TextEditingController(text: '*');
  final _sortC = TextEditingController(text: '0');

  String? _editId;
  String _gateway = 'cashfree';
  bool _loading = false, _saving = false, _active = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_editId == null) {
      _editId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_editId != null) _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final m = await _admin.getPaymentMethod(_editId!);
      if (mounted) {
        _codeC.text = m.code;
        _nameC.text = m.name;
        _descC.text = m.description ?? '';
        _iconC.text = m.iconUrl ?? '';
        _regionsC.text = m.regions;
        _sortC.text = m.sortOrder.toString();
        _gateway = m.gateway;
        _active = m.isActive;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _codeC.dispose();
    _nameC.dispose();
    _descC.dispose();
    _iconC.dispose();
    _regionsC.dispose();
    _sortC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = <String, dynamic>{
      'code': _codeC.text.trim(),
      'name': _nameC.text.trim(),
      'description': _descC.text.trim().isEmpty ? null : _descC.text.trim(),
      'icon_url': _iconC.text.trim().isEmpty ? null : _iconC.text.trim(),
      'gateway': _gateway,
      'regions': _regionsC.text.trim().isEmpty ? '*' : _regionsC.text.trim(),
      'sort_order': int.tryParse(_sortC.text.trim()) ?? 0,
      'is_active': _active,
    };
    try {
      if (_editId != null) {
        await _admin.updatePaymentMethod(_editId!, data);
      } else {
        await _admin.createPaymentMethod(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().length > 120 ? e.toString().substring(0, 120) : e.toString()),
          backgroundColor: AppColors.error,
        ));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _loading
          ? const BrandLoader(label: 'Loading')
          : Column(children: [
              BrandHeader(title: _editId != null ? 'Edit Payment Method' : 'New Payment Method'),
              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(key: _fk, child: Column(children: [
                  FormSection(title: 'What the customer sees', children: [
                    StyledInput(
                      controller: _nameC,
                      label: 'Display Name *',
                      hint: 'e.g. UPI',
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    StyledInput(
                      controller: _descC,
                      label: 'Description',
                      hint: 'e.g. Pay using any UPI app',
                    ),
                    StyledInput(
                      controller: _iconC,
                      label: 'Icon URL',
                      hint: 'Optional — a built-in icon is used when empty',
                    ),
                  ]),
                  const SizedBox(height: 16),
                  FormSection(title: 'Configuration', children: [
                    const _HelpBox(
                      lines: [
                        'Code must match the gateway\'s own method name — upi, card, netbanking or wallet. It opens the checkout on that method.',
                        'Regions: comma-separated country codes (IN, or IN,AE), or * for everywhere. UPI is India-only.',
                        'Lower sort order appears first at checkout.',
                      ],
                    ),
                    const SizedBox(height: 12),
                    StyledInput(
                      controller: _codeC,
                      label: 'Code *',
                      hint: 'upi / card / netbanking / wallet',
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    StyledDropdown(
                      label: 'Gateway',
                      value: _gateway,
                      items: AdminPaymentMethod.gatewayOptions
                          .map((g) => DropdownMenuItem<String>(
                                value: g,
                                child: Text(g[0].toUpperCase() + g.substring(1),
                                    style: TextStyle(color: AppColors.textPrimary)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _gateway = v ?? 'cashfree'),
                    ),
                    StyledInput(controller: _regionsC, label: 'Regions', hint: '* or IN,AE'),
                    StyledInput(controller: _sortC, label: 'Sort Order', hint: '0 = first', number: true),
                    ToggleRow(label: 'Active', value: _active, onChanged: (v) => setState(() => _active = v)),
                  ]),
                  const SizedBox(height: 32),
                  FashionButton(
                    label: _editId != null ? 'Update Method' : 'Create Method',
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                  const SizedBox(height: 40),
                ])),
              )),
            ]),
    );
  }
}

class _HelpBox extends StatelessWidget {
  final List<String> lines;

  const _HelpBox({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 15, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(line,
                        style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
