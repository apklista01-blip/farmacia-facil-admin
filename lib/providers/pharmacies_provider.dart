import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pharmacy_model.dart';

class PharmaciesNotifier extends Notifier<List<PharmacyModel>> {
  final _firestore = FirebaseFirestore.instance;

  @override
  List<PharmacyModel> build() {
    Future.microtask(loadPharmacies);
    return [];
  }

  Future<void> loadPharmacies() async {
    try {
      final snapshot = await _firestore.collection('pharmacies').get();
      state = snapshot.docs.map((doc) {
        final data = doc.data();
        return PharmacyModel.fromMap({'id': doc.id, ...data});
      }).toList();
      _log('Farmácias carregadas: ${state.length}');
    } catch (e) {
      _log('Erro ao carregar farmácias: $e');
    }
  }

  Future<void> updatePharmacy(String id, {bool? isApproved, bool? isActive}) async {
    try {
      final updates = <String, dynamic>{};
      if (isApproved != null) updates['isApproved'] = isApproved;
      if (isActive != null) updates['isActive'] = isActive;
      if (updates.isEmpty) return;
      await _firestore.collection('pharmacies').doc(id).update(updates);
      state = state.map((p) {
        if (p.id != id) return p;
        return p.copyWith(isApproved: isApproved, isActive: isActive);
      }).toList();
    } catch (e) {
      _log('Erro ao atualizar farmácia: $e');
    }
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[Pharmacies] $msg');
  }
}

final pharmaciesProvider = NotifierProvider<PharmaciesNotifier, List<PharmacyModel>>(
  PharmaciesNotifier.new,
);
