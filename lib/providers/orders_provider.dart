import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrdersNotifier extends Notifier<List<OrderModel>> {
  final _firestore = FirebaseFirestore.instance;

  @override
  List<OrderModel> build() {
    Future.microtask(loadOrders);
    return [];
  }

  Future<void> loadOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      state = snapshot.docs
          .map((doc) => OrderModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
      _log('Pedidos carregados: ${state.length}');
    } catch (e) {
      _log('Erro ao carregar pedidos: $e');
    }
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[Orders] $msg');
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<OrderModel>>(
  OrdersNotifier.new,
);
