import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../models/fulfillment.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../widgets.dart';

/// Returns queue: review return/replace requests, approve (issues a pickup
/// OTP) or reject with a reason, then verify the pickup OTP.
class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  final AdminService _admin = AdminService(ApiService());
  List<FulfillmentOrder> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final o = await _admin.getReturnOrders();
      if (mounted) setState(() { _orders = o; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  String _label(String? s) {
    switch (s) {
      case 'requested': return 'REQUESTED';
      case 'replace_requested': return 'REPLACE REQUESTED';
      case 'approved': return 'APPROVED';
      case 'rejected': return 'REJECTED';
      case 'picked_up': return 'PICKED UP';
      default: return (s ?? '').toUpperCase();
    }
  }

  Color _color(String? s) {
    switch (s) {
      case 'requested': return AppColors.warning;
      case 'replace_requested': return AppColors.warning;
      case 'approved': return AppColors.info;
      case 'rejected': return AppColors.error;
      case 'picked_up': return AppColors.success;
      default: return AppColors.textMuted;
    }
  }

  Future<void> _approve(FulfillmentOrder o) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.assignment_turned_in, color: AppColors.success, size: 16)),
          const SizedBox(width: 12),
          Text('Approve Return', style: AppColors.heading(color: AppColors.textPrimary, size: 16, weight: FontWeight.w700)),
        ]),
        content: Text('Approve the return/replace request for #${o.orderNumber}? A pickup OTP will be sent to the customer.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('CANCEL', style: TextStyle(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('APPROVE', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final res = await _admin.approveReturn(o.id);
      if (!mounted) return;
      final otp = res['pickup_otp'] as String? ?? '';
      _load();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.local_shipping, color: AppColors.success, size: 16)),
            const SizedBox(width: 12),
            Text('Return Approved', style: AppColors.heading(color: AppColors.textPrimary, size: 16, weight: FontWeight.w700)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#${o.orderNumber}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 14),
            Text('Pickup OTP (relay to the customer):', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 8),
            Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: AppColors.bgAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Text(otp, style: const TextStyle(color: AppColors.coral, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 8)),
            )),
            const SizedBox(height: 10),
            Text('Expires in 10 minutes. The customer reads this back to the pickup partner.', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w700))),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().substring(0, e.toString().length > 90 ? 90 : e.toString().length))));
    }
  }

  Future<void> _reject(FulfillmentOrder o) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 16)),
          const SizedBox(width: 12),
          Text('Reject Return', style: AppColors.heading(color: AppColors.textPrimary, size: 16, weight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('#${o.orderNumber}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Text('Reason (sent to the customer):', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            maxLines: 3,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'e.g. Item shows signs of use beyond the return window',
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
              filled: true, fillColor: AppColors.bgAlt,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.error, width: 1.6)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('CANCEL', style: TextStyle(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('REJECT', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed != true) return;
    if (ctrl.text.trim().isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A rejection reason is required')));
      return;
    }
    try {
      await _admin.rejectReturn(o.id, ctrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return rejected')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().substring(0, e.toString().length > 90 ? 90 : e.toString().length))));
    }
  }

  Future<void> _verifyPickup(FulfillmentOrder o) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.verified_user_outlined, color: AppColors.success, size: 16)),
          const SizedBox(width: 12),
          Text('Verify Pickup', style: AppColors.heading(color: AppColors.textPrimary, size: 16, weight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('#${o.orderNumber}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 14),
          Text('Enter the pickup OTP the customer read out:', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 6),
              decoration: InputDecoration(
                filled: true, fillColor: AppColors.bgAlt,
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.coral, width: 1.6)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('CANCEL', style: TextStyle(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('COMPLETE PICKUP', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _admin.verifyReturnPickup(o.id, ctrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return pickup complete')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().substring(0, e.toString().length > 90 ? 90 : e.toString().length))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/returns',
      body: Column(children: [
        Builder(builder: (ctx) => BrandHeader(title: 'Returns', subtitle: '${_orders.length} TOTAL', onMenuTap: () => Scaffold.of(ctx).openDrawer())),
        Expanded(child: _loading
          ? const BrandLoader(label: 'Loading')
          : _orders.isEmpty
            ? const EmptyBox(icon: Icons.assignment_return_outlined, message: 'No return requests')
            : RefreshIndicator(color: AppColors.coral, backgroundColor: AppColors.surface, onRefresh: _load, child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                children: _orders.map((o) => _returnCard(o)).toList(),
              )),
        ),
      ]),
    );
  }

  Widget _returnCard(FulfillmentOrder o) {
    final status = o.returnStatus;
    return ListCardShell(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('#${o.orderNumber}', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Tag(text: _label(status), color: _color(status)),
        ]),
        const SizedBox(height: 6),
        Text('${o.user.fullName} · ${o.user.email}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        if (o.returnReason != null && o.returnReason!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Reason: ${o.returnReason}', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
        if (o.returnAdminNote != null && o.returnAdminNote!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Admin note: ${o.returnAdminNote}', style: const TextStyle(color: AppColors.error, fontSize: 12)),
        ],
        if (o.returnEvidence.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('EVIDENCE', style: AppColors.heading(color: AppColors.textMuted, size: 9, letterSpacing: 2, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          SizedBox(height: 64, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: o.returnEvidence.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final url = o.returnEvidence[i];
              final full = url.startsWith('http') ? url : '${ApiConfig.baseUrl}$url';
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onTap: () => showDialog(context: context, builder: (ctx) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: CachedNetworkImage(imageUrl: full, fit: BoxFit.contain, placeholder: (_, __) => Container(color: AppColors.bgAlt, child: const Center(child: CircularProgressIndicator())), errorWidget: (_, __, ___) => Container(color: AppColors.bgAlt, width: 200, height: 200, child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted))),
                    ),
                  )),
                  child: CachedNetworkImage(imageUrl: full, width: 64, height: 64, fit: BoxFit.cover, placeholder: (_, __) => Container(width: 64, height: 64, color: AppColors.bgAlt, child: const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)))), errorWidget: (_, __, ___) => Container(width: 64, height: 64, color: AppColors.bgAlt, child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted, size: 18))),
                ),
              );
            },
          )),
        ],
        const SizedBox(height: 12),
        if (o.hasPendingReturn)
          Row(children: [
            Expanded(child: FashionButton(label: 'Reject', color: AppColors.error, icon: Icons.close, onPressed: () => _reject(o))),
            const SizedBox(width: 10),
            Expanded(child: FashionButton(label: 'Approve', color: AppColors.success, icon: Icons.check, onPressed: () => _approve(o))),
          ])
        else if (o.returnApproved)
          FashionButton(label: 'Verify Pickup OTP', color: AppColors.teal, icon: Icons.verified_outlined, onPressed: () => _verifyPickup(o)),
      ]),
    );
  }
}
