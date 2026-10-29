import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UsersNotifier extends Notifier<List<UserModel>> {
  final _firestore = FirebaseFirestore.instance;

  @override
  List<UserModel> build() {
    Future.microtask(loadUsers);
    return [];
  }

  Future<void> loadUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      state = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromMap({'id': doc.id, ...data});
      }).toList();
      _log('Usuários carregados: ${state.length}');
    } catch (e) {
      _log('Erro ao carregar usuários: $e');
    }
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[Users] $msg');
  }
}

final usersProvider = NotifierProvider<UsersNotifier, List<UserModel>>(
  UsersNotifier.new,
);
