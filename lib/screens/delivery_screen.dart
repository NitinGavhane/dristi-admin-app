import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/fulfillment.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../widgets.dart';

/// Delivery dashboard: orders awaiting dispatch and parcels in transit.
/// Dispatch issues a delivery OTP to the customer; verification of that OTP by
/// the delivery partner marks the order delivered.
class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final AdminService _admin = AdminService(ApiService());
  List<FulfillmentOrder> _orders = [];
  bool _loading = true;
  /// orderId -> live ShipRocket status string (from the tracking endpoint).
  final Map<String, String> _liveStatus = {};
  /// orderId -> true while a live refresh is in flight.
  final Set<String> _refreshing = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final o = await _admin.getDeliveryOrders();
      if (mounted) setState(() { _orders = o; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  /// Pulls the latest ShipRocket status for one in-transit order.
  Future<void> _refreshTracking(FulfillmentOrder o) async {
    if (_refreshing.contains(o.id)) return;
    setState(() => _refreshing.add(o.id));
    try {
      final res = await _admin.getDeliveryTracking(o.id);
      final live = (res['shipment_status'] as String?) ?? o.shipmentStatus;
      if (mounted && live != null) {
        setState(() { _liveStatus[o.id] = live; });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not refresh tracking status')),
      );
    } finally {
      if (mounted) setState(() => _refreshing.remove(o.id));
    }
  }

  Color _sc(String s) {
    switch (s) {
      case 'placed': return AppColors.info;
      case 'processing': return AppColors.warning;
      case 'dispatched': return AppColors.purple;
      case 'out_for_delivery': return AppColors.teal;
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textMuted;
    }
  }

  String _sd(String s) {
    switch (s) {
      case 'placed': return 'PLACED';
      case 'processing': return 'PROCESSING';
      case 'dispatched': return 'DISPATCHED';
      case 'out_for_delivery': return 'OUT FOR DELIVERY';
      case 'delivered': return 'DELIVERED';
      case 'cancelled': return 'CANCELLED';
      default: return s.toUpperCase();
    }
  }

  Future<void> _dispatch(FulfillmentOrder o) async {
    try {
      final res = await _admin.dispatchOrder(o.id);
      if (!mounted) return;
      final otp = res['delivery_otp'] as String? ?? '';
      _load();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.local_shipping, color: AppColors.success, size: 16)),
            const SizedBox(width: 12),
            Text('Order Dispatched', style: AppColors.heading(color: AppColors.textPrimary, size: 16, weight: FontWeight.w700)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#${o.orderNumber}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 14),
            Text('Delivery OTP (relay this to the customer):', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 8),
            Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: AppColors.bgAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Text(otp, style: const TextStyle(color: AppColors.coral, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 8)),
            )),
            const SizedBox(height: 10),
            Text('Expires in 10 minutes. The customer reads this back to the delivery partner.', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
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

  Future<void> _verifyDelivery(FulfillmentOrder o) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.verified_user_outlined, color: AppColors.success, size: 16)),
          const SizedBox(width: 12),
          Text('Verify Delivery', style: AppColors.heading(color: AppColors.textPrimary, size: 16, weight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('#${o.orderNumber}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 14),
            Text('Enter the delivery OTP the customer read out:', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('CANCEL', style: TextStyle(color: AppColors.textMuted))),          const SizedBox(width: 8),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('VERIFY', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _admin.verifyDeliveryOtp(o.id, ctrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery confirmed')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().substring(0, e.toString().length > 90 ? 90 : e.toString().length))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final awaiting = _orders.where((o) => o.needsDispatch).toList();
    final transit = _orders.where((o) => o.inTransit).toList();
    return AdminScaffold(
      currentRoute: '/delivery',
      body: Column(children: [
        Builder(builder: (ctx) => BrandHeader(title: 'Delivery', subtitle: '${awaiting.length} TO DISPATCH · ${transit.length} IN TRANSIT', onMenuTap: () => Scaffold.of(ctx).openDrawer())),
        Expanded(child: _loading
          ? const BrandLoader(label: 'Loading')
          : RefreshIndicator(color: AppColors.coral, backgroundColor: AppColors.surface, onRefresh: _load, child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                if (awaiting.isNotEmpty) const SectionLabel(title: 'Awaiting Dispatch'),
                if (awaiting.isNotEmpty)
                  ...awaiting.map((o) => _deliveryCard(o, dispatch: true)),
                if (transit.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const SectionLabel(title: 'In Transit'),
                ],
                if (transit.isNotEmpty)
                  ...transit.map((o) => _deliveryCard(o, dispatch: false)),
                if (awaiting.isEmpty && transit.isEmpty)
                  const EmptyBox(icon: Icons.local_shipping, message: 'No active deliveries'),
              ],
            )),
        ),
      ]),
    );
  }

  Widget _deliveryCard(FulfillmentOrder o, {required bool dispatch}) {
    final sc = _sc(o.orderStatus);
    final liveStatus = _liveStatus[o.id] ?? o.shipmentStatus;
    return ListCardShell(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('#${o.orderNumber}', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Tag(text: _sd(o.orderStatus), color: sc),
        ]),
        const SizedBox(height: 6),
        Text(o.user.fullName, style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
        Text(o.user.email, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        if (o.shippingAddress != null) ...[
          const SizedBox(height: 4),
          Text(o.shippingAddress!, style: TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
        if (o.awbCode != null || o.courierName != null) ...[
          const SizedBox(height: 8),
          if (o.courierName != null)
            Text('Courier: ${o.courierName}', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12)),
          if (o.awbCode != null)
            Text('AWB: ${o.awbCode}', style: TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (liveStatus != null)
            Text('Status: $liveStatus', style: TextStyle(color: AppColors.success, fontSize: 12)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Text('₹${o.finalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.coral, fontWeight: FontWeight.w900, fontSize: 16)),
          const Spacer(),
          if (_refreshing.contains(o.id))
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (o.trackingUrl != null || o.awbCode != null) ...[
            FashionButton(label: 'Refresh', color: AppColors.info, icon: Icons.refresh,
              onPressed: () => _refreshTracking(o)),
            const SizedBox(width: 8),
          ],
          if (o.trackingUrl != null) ...[
            FashionButton(label: 'Track', color: AppColors.info, icon: Icons.local_shipping, onPressed: () => _track(o.trackingUrl!)),
            const SizedBox(width: 8),
          ],
          if (dispatch)
            FashionButton(label: 'Dispatch', color: AppColors.success, icon: Icons.local_shipping, onPressed: () => _dispatch(o))
          else
            FashionButton(label: 'Verify OTP', color: AppColors.teal, icon: Icons.verified_outlined, onPressed: () => _verifyDelivery(o)),
        ]),
      ]),
    );
  }

  Future<void> _track(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().substring(0, e.toString().length > 90 ? 90 : e.toString().length))));
    }
  }
}
