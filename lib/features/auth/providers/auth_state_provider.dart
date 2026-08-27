import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/env.dart';
import '../../onboarding/models/onboarding_enums.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';

/// Coarse app-state:
/// - unauthenticated: login gate
/// - onboarding: filling out the wizard (draft profile)
/// - awaitingReview: profile submitted, waiting for admin approval —
///   nav bar hidden, user locked on the review screen
/// - authenticated: approved, full app access
enum AuthStatus { unauthenticated, onboarding, awaitingReview, authenticated }

final stubSignedInProvider = StateProvider<bool>((ref) => false);

final authStateProvider = Provider<AuthStatus>((ref) {
  if (Env.skipOnboarding) return AuthStatus.authenticated;

  final bool signedIn = ref.watch(stubSignedInProvider);
  if (!signedIn) return AuthStatus.unauthenticated;

  final ProfileReviewStatus reviewStatus = ref.watch(
    onboardingDraftProvider.select((draft) => draft.reviewStatus),
  );
  return switch (reviewStatus) {
    ProfileReviewStatus.draft => AuthStatus.onboarding,
    ProfileReviewStatus.submitted ||
    ProfileReviewStatus.underReview =>
      AuthStatus.awaitingReview,
    ProfileReviewStatus.approved => AuthStatus.authenticated,
    ProfileReviewStatus.rejected => AuthStatus.awaitingReview,
  };
});
