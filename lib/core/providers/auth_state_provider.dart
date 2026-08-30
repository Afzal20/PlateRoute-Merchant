import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/token_storage.dart';
import 'core_providers.dart';

/// Auth state held in memory, initialized from secure storage.
class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.needsOnboarding = false,
    this.vendorStatus,
  });

  final bool isAuthenticated;
  final bool needsOnboarding;
  final String? vendorStatus; // 'pending' | 'approved' | 'paused'

  AuthState copyWith({
    bool? isAuthenticated,
    bool? needsOnboarding,
    String? vendorStatus,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
      vendorStatus: vendorStatus ?? this.vendorStatus,
    );
  }
}

class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Initialize from token storage asynchronously
    _init();
    return const AuthState();
  }

  Future<void> _init() async {
    final storage = ref.read(tokenStorageProvider);
    final has = await storage.hasTokens();
    if (has) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<void> signIn({
    required String access,
    required String refresh,
    required String vendorStatus,
  }) async {
    final storage = ref.read(tokenStorageProvider);
    await storage.saveTokens(access: access, refresh: refresh);
    state = AuthState(
      isAuthenticated: true,
      needsOnboarding: vendorStatus != 'approved',
      vendorStatus: vendorStatus,
    );
  }

  Future<void> signOut() async {
    final storage = ref.read(tokenStorageProvider);
    await storage.clear();
    state = const AuthState();
  }

  void setVendorStatus(String status) {
    state = state.copyWith(
      needsOnboarding: status != 'approved',
      vendorStatus: status,
    );
  }
}

final authStateProvider =
    NotifierProvider<AuthStateNotifier, AuthState>(AuthStateNotifier.new);
