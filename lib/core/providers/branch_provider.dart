import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

class BranchState {
  const BranchState({this.branchUuid, this.isAccepting = false});
  final String? branchUuid;
  final bool isAccepting;
}

class BranchNotifier extends Notifier<BranchState> {
  @override
  BranchState build() {
    _fetch();
    return const BranchState();
  }

  Future<void> _fetch() async {
    try {
      final dio = await ref.read(apiClientProvider.future);
      // Fetch branches associated with this user
      final resp = await dio.dio.get('/branches/');
      final results = resp.data['results'] as List;
      if (results.isNotEmpty) {
        final branch = results.first as Map<String, dynamic>;
        state = BranchState(
          branchUuid: branch['uuid'] as String?,
          isAccepting: branch['is_accepting'] as bool? ?? false,
        );
      }
    } catch (_) {
      // Ignored for now
    }
  }

  Future<void> toggleAccepting(bool value) async {
    if (state.branchUuid == null) return;
    
    // Optimistic
    final oldState = state;
    state = BranchState(branchUuid: oldState.branchUuid, isAccepting: value);
    
    try {
      final dio = await ref.read(apiClientProvider.future);
      await dio.dio.patch(
        '/branches/${state.branchUuid}/',
        data: {'is_accepting': value},
      );
    } catch (_) {
      // Revert on error
      state = oldState;
    }
  }
}

final branchProvider = NotifierProvider<BranchNotifier, BranchState>(BranchNotifier.new);
