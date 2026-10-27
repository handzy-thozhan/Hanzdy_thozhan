import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../../core/theme/app_colors.dart';
import '../../services/order_sound_service.dart';

class WorkerOrderScreen extends StatefulWidget {
  final List<String> selectedFields;

  const WorkerOrderScreen({super.key, required this.selectedFields});

  @override
  State<WorkerOrderScreen> createState() => _WorkerOrderScreenState();
}

class _WorkerOrderScreenState extends State<WorkerOrderScreen> {
  // Sound-only additions. Existing order screen logic is kept unchanged.
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _orderSoundSubscription;
  final Set<String> _knownOrderIds = <String>{};
  bool _isFirstOrderSoundSnapshot = true;

  int _selectedTab = 0;
  final Set<String> _busyOrderIds = <String>{};
  static const List<String> _tabs = ['New', 'Accepted', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _startOrderSoundListener();
  }

  @override
  void dispose() {
    _orderSoundSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startOrderSoundListener() async {
    try {
      await OrderSoundService.instance.initialize();
      if (!mounted) return;

      _orderSoundSubscription = FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'searching')
          .snapshots()
          .listen((snapshot) async {
        // Register current orders silently; only later-added orders alert.
        if (_isFirstOrderSoundSnapshot) {
          _knownOrderIds.addAll(snapshot.docs.map((doc) => doc.id));
          _isFirstOrderSoundSnapshot = false;
          return;
        }

        for (final change in snapshot.docChanges) {
          if (change.type != DocumentChangeType.added) continue;
          final doc = change.doc;
          if (!_knownOrderIds.add(doc.id)) continue;

          final data = doc.data();

        if (data == null) continue;

        if (!_matchesProfession(data)) continue;
        if (_isRejectedByMe(data)) continue;

         final assigned = data['assignedWorkerUid'];
         if (assigned != null && assigned.toString().isNotEmpty) {
             continue;
            }

        await OrderSoundService.instance.showNewOrder(
        orderId: doc.id,
        profession: (data['professionName'] ?? 'Service').toString(),
        problemType: (data['problemType'] ?? '').toString(),
         );
        }
      }, onError: (Object error) {
        debugPrint('Order sound listener error: $error');
      });
    } catch (error) {
      debugPrint('Could not initialize order sound: $error');
    }
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String _norm(String value) => value.trim().toLowerCase();

  bool _matchesProfession(Map<String, dynamic> data) {
    final String profession = _norm((data['professionName'] ?? '').toString());
    return widget.selectedFields.any((field) => _norm(field) == profession);
  }

  Query<Map<String, dynamic>> _query() {
    final orders = FirebaseFirestore.instance.collection('orders');
    switch (_selectedTab) {
      case 0:
        return orders.where('status', isEqualTo: 'searching');
      case 1:
      case 2:
      case 3:
        return orders.where('assignedWorkerUid', isEqualTo: _uid);
      default:
        return orders.where('status', isEqualTo: 'searching');
    }
  }

  bool _isRejectedByMe(Map<String, dynamic> data) {
    final rejected = data['rejectedByWorkerUids'];
    return _uid != null && rejected is List && rejected.contains(_uid);
  }

  bool _matchesTab(Map<String, dynamic> data) {
    final status = _norm((data['status'] ?? '').toString());
    switch (_selectedTab) {
      case 0:
        return status == 'searching' &&
            (data['assignedWorkerUid'] == null || data['assignedWorkerUid'] == '') &&
            !_isRejectedByMe(data) && _matchesProfession(data);
      case 1:
        return data['assignedWorkerUid'] == _uid &&
            (status == 'accepted' || status == 'assigned');
      case 2:
        return data['assignedWorkerUid'] == _uid && status == 'in_progress';
      case 3:
        return data['assignedWorkerUid'] == _uid && status == 'completed';
      default:
        return false;
    }
  }

  String _areaFromAddress(String address) {
    final parts = address.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    // Approximation only: address formats vary, so this is not guaranteed to be the locality.
    if (parts.length >= 3) return parts[1];
    if (parts.length == 2) return parts[1];
    return address.isEmpty ? 'Not provided' : address;
  }

  String _timeLabel(dynamic value) {
    if (value is! Timestamp) return 'Booking time unavailable';
    final time = value.toDate();
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  Future<void> _acceptOrder(String id, Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) return _message('Please sign in again.');
    if (!_matchesProfession(data)) return _message('This order does not match your services.');
    setState(() => _busyOrderIds.add(id));
    try {
      final ref = FirebaseFirestore.instance.collection('orders').doc(id);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists) throw StateError('This order is no longer available.');
        final latest = snapshot.data()!;
        final status = _norm((latest['status'] ?? '').toString());
        final assigned = latest['assignedWorkerUid'];
        if (status != 'searching' || (assigned != null && assigned.toString().isNotEmpty)) {
          throw StateError('This order has already been taken.');
        }
        if (!_matchesProfession(latest)) throw StateError('This order does not match your services.');
        transaction.update(ref, {
          'status': 'accepted',
          'assignedWorkerUid': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      _message('Order accepted successfully.');
      if (mounted) setState(() => _selectedTab = 1);
    } on StateError catch (e) {
      _message(e.message.toString());
    } on FirebaseException catch (e) {
      _message(e.code == 'permission-denied' ? 'Permission denied. Check Firestore rules.' : 'Could not accept this order.');
    } catch (_) {
      _message('Could not accept this order. Please try again.');
    } finally {
      if (mounted) setState(() => _busyOrderIds.remove(id));
    }
  }

  Future<void> _rejectOrder(String id) async {
    final uid = _uid;
    if (uid == null) return _message('Please sign in again.');
    setState(() => _busyOrderIds.add(id));
    try {
      await FirebaseFirestore.instance.collection('orders').doc(id).update({
        // This hides the order for this worker without rejecting it for every worker.
        'rejectedByWorkerUids': FieldValue.arrayUnion([uid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _message('Order hidden from your new orders.');
    } on FirebaseException catch (e) {
      _message(e.code == 'permission-denied' ? 'Permission denied. Check Firestore rules.' : 'Could not reject this order.');
    } catch (_) {
      _message('Could not reject this order. Please try again.');
    } finally {
      if (mounted) setState(() => _busyOrderIds.remove(id));
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    setState(() => _busyOrderIds.add(id));
    try {
      await FirebaseFirestore.instance.collection('orders').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _message(status == 'in_progress' ? 'Work started.' : 'Order completed.');
    } on FirebaseException catch (e) {
      _message(e.code == 'permission-denied' ? 'Permission denied. Check Firestore rules.' : 'Could not update order status.');
    } catch (_) {
      _message('Could not update order status.');
    } finally {
      if (mounted) setState(() => _busyOrderIds.remove(id));
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text), backgroundColor: AppColors.darkTeal,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Please sign in to view orders.', style: TextStyle(color: AppColors.textPrimary))),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        _buildServices(),
        _buildTabs(),
        Expanded(child: _buildOrders()),
      ])),
    );
  }

  Widget _buildHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [AppColors.headerMiddle, AppColors.headerEnd],
      ),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: .20), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: const Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Incoming Orders', style: TextStyle(color: AppColors.white, fontSize: 21, fontWeight: FontWeight.w800)),
        SizedBox(height: 4),
        Text('Bookings matching your services', style: TextStyle(color: AppColors.lightMint, fontSize: 12)),
      ])),
      Icon(Icons.receipt_long_rounded, color: AppColors.white, size: 28),
    ]),
  );

  Widget _buildServices() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Your Services', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      SizedBox(height: 38, child: widget.selectedFields.isEmpty
        ? const Align(alignment: Alignment.centerLeft, child: Text('No services selected', style: TextStyle(color: AppColors.textSecondary)))
        : ListView.separated(scrollDirection: Axis.horizontal, itemCount: widget.selectedFields.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12), alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.lightMint, borderRadius: BorderRadius.circular(13), border: Border.all(color: AppColors.border)),
            child: Text(widget.selectedFields[index], style: const TextStyle(color: AppColors.darkTeal, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ]),
  );

  Widget _buildTabs() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Container(height: 46, padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
      child: Row(children: List.generate(_tabs.length, (index) {
        final selected = _selectedTab == index;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _selectedTab = index),
          child: Container(alignment: Alignment.center,
            decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(11)),
            child: FittedBox(fit: BoxFit.scaleDown, child: Text(_tabs[index], style: TextStyle(
              color: selected ? AppColors.white : AppColors.textSecondary, fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ))),
          ),
        ));
      })),
    ),
  );

  Widget _buildOrders() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: _query().snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return _state(Icons.cloud_off_rounded, 'Unable to load orders', 'Check internet connection and Firestore rules.');
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      final docs = (snapshot.data?.docs ?? []).where((doc) => _matchesTab(doc.data())).toList()
        ..sort((a, b) {
          final aTime = a.data()['createdAt']; final bTime = b.data()['createdAt'];
          final aMs = aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
          final bMs = bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
          return bMs.compareTo(aMs);
        });
      if (docs.isEmpty) return _state(Icons.inbox_rounded,
        _selectedTab == 0 ? 'No incoming orders' : 'No orders here yet',
        _selectedTab == 0 ? 'New bookings matching your services will appear here.' : 'Orders assigned to you will appear here.');
      return ListView.separated(padding: const EdgeInsets.fromLTRB(16, 0, 16, 20), itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _orderCard(docs[index].id, docs[index].data()),
      );
    },
  );

  Widget _orderCard(String id, Map<String, dynamic> data) {
    final profession = (data['professionName'] ?? 'Service').toString();
    final problem = (data['problemType'] ?? 'Problem not specified').toString();
    final address = (data['address'] ?? 'Address unavailable').toString();
    final rawAmount = data['amount'];
    final num amount = rawAmount is num ? rawAmount : num.tryParse('$rawAmount') ?? 0;
    final status = (data['status'] ?? 'searching').toString();
    final busy = _busyOrderIds.contains(id);
    final amountText = amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: .16), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.lightMint, borderRadius: BorderRadius.circular(14)),
            child: Icon(_serviceIcon(profession), color: AppColors.primary, size: 25)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(profession, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3), Text(_timeLabel(data['createdAt']), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ])),
          const SizedBox(width: 6),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹$amountText', style: const TextStyle(color: AppColors.darkTeal, fontSize: 19, fontWeight: FontWeight.w900)),
            Text(status.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.w800)),
          ]),
        ]),
        const SizedBox(height: 14),
        _info(Icons.build_outlined, 'Problem', problem),
        const SizedBox(height: 8),
        _info(Icons.map_outlined, 'Main area', _areaFromAddress(address)),
        const SizedBox(height: 8),
        _info(Icons.location_on_outlined, 'Address', address),
        const SizedBox(height: 14),
        if (_selectedTab == 0) Row(children: [
          Expanded(child: OutlinedButton(onPressed: busy ? null : () => _rejectOrder(id),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), minimumSize: const Size(0, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w800)))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(onPressed: busy ? null : () => _acceptOrder(id, data),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, minimumSize: const Size(0, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
            child: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)) : const Text('Accept Order', style: TextStyle(fontWeight: FontWeight.w800)))),
        ]) else if (_selectedTab == 1)
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: busy ? null : () => _updateStatus(id, 'in_progress'), child: const Text('Start Work')))
        else if (_selectedTab == 2)
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: busy ? null : () => _updateStatus(id, 'completed'), child: const Text('Mark Completed'))),
      ]),
    );
  }

  Widget _info(IconData icon, String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: AppColors.primary, size: 18), const SizedBox(width: 8),
    SizedBox(width: 82, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600))),
    Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600))),
  ]);

  IconData _serviceIcon(String value) {
    switch (_norm(value)) {
      case 'plumber': case 'plumbing': return Icons.plumbing_rounded;
      case 'electrician': return Icons.electrical_services_rounded;
      case 'ac service': return Icons.ac_unit_rounded;
      case 'cleaning': case 'home cleaner': return Icons.cleaning_services_rounded;
      case 'carpenter': return Icons.handyman_rounded;
      case 'gardening': return Icons.yard_rounded;
      default: return Icons.home_repair_service_rounded;
    }
  }

  Widget _state(IconData icon, String title, String subtitle) => Center(child: Padding(
    padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 76, height: 76, decoration: const BoxDecoration(color: AppColors.lightMint, shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 36)),
      const SizedBox(height: 16), Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 7), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
    ]),
  ));
}
