import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/users_provider.dart';
import '../../providers/pharmacies_provider.dart';
import '../../providers/orders_provider.dart';
import '../../models/order_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final pharmacies = ref.watch(pharmaciesProvider);
    final orders = ref.watch(ordersProvider);
    final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
    final approvedPharmacies = pharmacies.where((p) => p.isApproved).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(adminAuthProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo ao painel administrativo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(
                  title: 'Usuários',
                  value: users.length.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Farmácias',
                  value: pharmacies.length.toString(),
                  subtitle: '$approvedPharmacies aprovadas',
                  icon: Icons.store,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Pedidos',
                  value: orders.length.toString(),
                  icon: Icons.receipt_long,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Pendentes',
                  value: pendingOrders.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(icon, color: color),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.white70)),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
