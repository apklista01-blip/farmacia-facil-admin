import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Estado ──────────────────────────────────────────────────────────────────
class AdminAuthState {
  final bool isAdmin;
  final bool isLoading;
  final String? errorMessage;
  final String? adminEmail;

  const AdminAuthState({
    this.isAdmin = false,
    this.isLoading = true,
    this.errorMessage,
    this.adminEmail,
  });

  AdminAuthState copyWith({
    bool? isAdmin,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? adminEmail,
  }) {
    return AdminAuthState(
      isAdmin: isAdmin ?? this.isAdmin,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      adminEmail: adminEmail ?? this.adminEmail,
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────
class AdminAuthNotifier extends Notifier<AdminAuthState> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _ignoreNextAuthChange = false;

  @override
  AdminAuthState build() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    return const AdminAuthState(isLoading: true);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (_ignoreNextAuthChange) {
      _ignoreNextAuthChange = false;
      return;
    }
    if (firebaseUser == null) {
      state = const AdminAuthState(isLoading: false);
      return;
    }
    await _verifyAdmin(firebaseUser);
  }

  Future<void> _verifyAdmin(User firebaseUser) async {
    try {
      final doc = await _firestore.collection('admins').doc(firebaseUser.uid).get();
      if (doc.exists) {
        state = AdminAuthState(
          isAdmin: true,
          isLoading: false,
          adminEmail: firebaseUser.email,
        );
      } else {
        await _auth.signOut();
        state = const AdminAuthState(
          isLoading: false,
          errorMessage: 'Acesso negado: esta conta não é administrador.',
        );
      }
    } catch (e) {
      await _auth.signOut();
      state = AdminAuthState(
        isLoading: false,
        errorMessage: 'Erro ao verificar permissões: $e',
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    if (email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(isLoading: false, errorMessage: 'Preencha e-mail e senha');
      return false;
    }
    try {
      _ignoreNextAuthChange = true;
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      await _verifyAdmin(credential.user!);
      return state.isAdmin;
    } on FirebaseAuthException catch (e) {
      _ignoreNextAuthChange = false;
      state = state.copyWith(isLoading: false, errorMessage: _translateError(e.code));
      return false;
    } catch (e) {
      _ignoreNextAuthChange = false;
      state = state.copyWith(isLoading: false, errorMessage: 'Erro ao fazer login. Tente novamente.');
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = const AdminAuthState(isLoading: false);
  }

  String _translateError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      default:
        return 'Erro de autenticação ($code). Tente novamente.';
    }
  }
}

final adminAuthProvider = NotifierProvider<AdminAuthNotifier, AdminAuthState>(
  AdminAuthNotifier.new,
);
