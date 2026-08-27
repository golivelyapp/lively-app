import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_step.dart';
import '../repositories/onboarding_repository.dart';
import '../repositories/supabase_onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return const SupabaseOnboardingRepository();
});

final onboardingStepProvider = StateProvider<OnboardingStep>((ref) {
  return OnboardingStep.intro;
});
