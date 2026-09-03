import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/env.dart';
import '../../../core/api/supabase_client.dart';
import '../../onboarding/models/onboarding_enums.dart';
import '../repositories/profile_repository.dart';

/// Coarse app-state driven by real Supabase Auth + the user's profile row:
/// - loading: session exists but profile hasn't returned yet (cold start).
///   The router keeps the user on the splash screen instead of guessing.
/// - unauthenticated: no session → login
/// - onboarding: authenticated but profile.review_status = 'draft'
/// - awaitingReview: submitted/under_review/rejected
/// - authenticated: approved — full app access
enum AuthStatus {
  loading,
  unauthenticated,
  onboarding,
  awaitingReview,
  authenticated,
}

/// Streams every Supabase auth state change (sign-in / sign-out / refresh).
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange;
});

/// Current session — null when signed out.
final sessionProvider = Provider<Session?>((ref) {
  ref.watch(authStateChangesProvider); // rebuild when auth changes
  return SupabaseService.client.auth.currentSession;
});

/// The current user's profile row. Null while loading or if no session.
/// Refreshes on every auth event and whenever profileRefreshTriggerProvider
/// is bumped (e.g., after onboarding writes a change locally).
final currentProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  ref.watch(authStateChangesProvider);
  ref.watch(profileRefreshTriggerProvider);
  final Session? session = SupabaseService.client.auth.currentSession;
  if (session == null) return null;
  return ref.read(profileRepositoryProvider).fetchMyProfile();
});

/// Bumped after any local profile mutation to force a re-fetch.
final profileRefreshTriggerProvider = StateProvider<int>((ref) => 0);

final authStateProvider = Provider<AuthStatus>((ref) {
  if (Env.skipOnboarding) return AuthStatus.authenticated;

  final Session? session = ref.watch(sessionProvider);
  if (session == null) return AuthStatus.unauthenticated;

  final profileAsync = ref.watch(currentProfileProvider);
  return profileAsync.when(
    // Cold-start: we know there's a session but the profile row hasn't
    // arrived yet. Report loading so the router keeps the user on the
    // splash screen instead of routing them into onboarding intro every
    // launch (which was the pre-fix behaviour).
    loading: () => AuthStatus.loading,
    error: (_, __) => AuthStatus.loading,
    data: (profile) {
      if (profile == null) return AuthStatus.onboarding;
      final String status = profile['review_status'] as String? ?? 'draft';
      return switch (status) {
        'draft' => AuthStatus.onboarding,
        'submitted' || 'under_review' || 'rejected' => AuthStatus.awaitingReview,
        'approved' => AuthStatus.authenticated,
        _ => AuthStatus.onboarding,
      };
    },
  );
});

/// The current user's gender — read from the profile. Falls back to
/// female so the "Women only" toggle is available in preview/skip mode.
final currentGenderProvider = Provider<Gender?>((ref) {
  final profileAsync = ref.watch(currentProfileProvider);
  return profileAsync.when(
    loading: () => null,
    error: (_, __) => null,
    data: (p) {
      final String? g = p?['gender'] as String?;
      return switch (g) {
        'male' => Gender.male,
        'female' => Gender.female,
        'other' => Gender.other,
        _ => null,
      };
    },
  );
});
