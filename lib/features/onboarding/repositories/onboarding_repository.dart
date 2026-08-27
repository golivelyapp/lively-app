import 'dart:io';
import '../models/onboarding_draft.dart';

abstract class OnboardingRepository {
  /// Uploads a local image file and returns its public storage path.
  Future<String> uploadPhoto(File file, {required String purpose});

  /// Persists the completed draft and flips it into review.
  Future<void> submitForReview(OnboardingDraft draft);
}
