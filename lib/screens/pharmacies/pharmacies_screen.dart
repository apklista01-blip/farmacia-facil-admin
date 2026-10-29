import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pharmacies_provider.dart';

class PharmaciesScreen extends ConsumerWidget {
  const PharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pharmacies = ref.watch(pharmaciesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Farmácias')),
      body: pharmacies.isEmpty
          ? const Center(child: Text('Nenhuma farmácia cadastrada.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pharmacies.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = pharmacies[i];
                return Card(
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text('${p.ownerName} • ${p.city}/${p.state}\n${p.email}'),
                    isThreeLine: true,
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(p.statusLabel),
                          backgroundColor: p.isApproved
                              ? (p.isActive ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2))
                              : Colors.orange.withValues(alpha: 0.2),
                        ),
                        if (!p.isApproved)
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            tooltip: 'Aprovar',
                            onPressed: () => ref
                                .read(pharmaciesProvider.notifier)
                                .updatePharmacy(p.id, isApproved: true),
                          ),
                        if (p.isApproved)
                          IconButton(
                            icon: Icon(p.isActive ? Icons.block : Icons.check_circle,
                                color: p.isActive ? Colors.red : Colors.green),
                            tooltip: p.isActive ? 'Desativar' : 'Ativar',
                            onPressed: () => ref
                                .read(pharmaciesProvider.notifier)
                                .updatePharmacy(p.id, isActive: !p.isActive),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
