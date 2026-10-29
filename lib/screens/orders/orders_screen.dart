import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orders_provider.dart';
import '../../models/order_model.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);
    final filtered = _filter == null
        ? orders
        : orders.where((o) => o.status == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          DropdownButton<OrderStatus?>(
            value: _filter,
            hint: const Text('Filtrar', style: TextStyle(color: Colors.white)),
            dropdownColor: const Color(0xFF1E293B),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem<OrderStatus?>(value: null, child: Text('Todos')),
              ...OrderStatus.values.map((s) => DropdownMenuItem<OrderStatus?>(
                    value: s,
                    child: Text(s.label),
                  )),
            ],
            onChanged: (v) => setState(() => _filter = v),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: filtered.isEmpty
          ? const Center(child: Text('Nenhum pedido encontrado.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final o = filtered[i];
                return Card(
                  child: ListTile(
                    title: Text('${o.userName} • ${o.pharmacyName}'),
                    subtitle: Text(
                      '${o.items.length} item(ns) • R\$ ${o.totalPrice.toStringAsFixed(2)}\n'
                      '${o.isDelivery ? 'Entrega' : 'Retirada'} • ${o.deliveryAddress}',
                    ),
                    isThreeLine: true,
                    trailing: Chip(label: Text('${o.status.emoji} ${o.status.label}')),
                  ),
                );
              },
            ),
    );
  }
}
