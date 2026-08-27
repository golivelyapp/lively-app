import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/env.dart';
import '../models/onboarding_draft.dart';
import '../models/onboarding_enums.dart';
import '../models/profile_prompt.dart';
import 'onboarding_providers.dart';

class OnboardingDraftController extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void updateBasics({
    String? name,
    DateTime? dateOfBirth,
    String? location,
    Gender? gender,
  }) {
    state = state.copyWith(
      name: name ?? state.name,
      dateOfBirth: dateOfBirth ?? state.dateOfBirth,
      location: location ?? state.location,
      gender: gender ?? state.gender,
    );
  }

  /// Optional post-onboarding fields — surfaced inside the Profile tab.
  void updateMoreAboutYou({
    String? company,
    String? profession,
    RelationshipStatus? status,
    int? heightCm,
    Set<String>? traits,
  }) {
    state = state.copyWith(
      company: company ?? state.company,
      profession: profession ?? state.profession,
      status: status ?? state.status,
      heightCm: heightCm ?? state.heightCm,
      traits: traits ?? state.traits,
    );
  }

  void setProfilePhoto(String path) {
    state = state.copyWith(profilePhotoPath: path);
  }

  void setHeightCm(int heightCm) {
    state = state.copyWith(heightCm: heightCm);
  }

  void setActivities(Set<String> activities) {
    state = state.copyWith(activities: activities);
  }

  void setTraits(Set<String> traits) {
    state = state.copyWith(traits: traits);
  }

  void updateMusicians(List<ProfilePrompt> prompts) {
    state = state.copyWith(musicians: prompts);
  }

  void updateMovies(List<ProfilePrompt> prompts) {
    state = state.copyWith(movies: prompts);
  }

  void updateDishes(List<ProfilePrompt> prompts) {
    state = state.copyWith(dishes: prompts);
  }

  void updateBio(String bio) {
    state = state.copyWith(bio: bio);
  }

  void updateSocials(List<SocialLink> socials) {
    state = state.copyWith(socials: socials);
  }

  void setSelfiePhoto(String path) {
    state = state.copyWith(selfiePhotoPath: path);
  }

  Future<void> submit() async {
    if (Env.hasSupabaseConfig) {
      final repository = ref.read(onboardingRepositoryProvider);
      final String profilePhotoUrl = await repository.uploadPhoto(
        File(state.profilePhotoPath!),
        purpose: 'profile',
      );
      final String selfiePhotoUrl = await repository.uploadPhoto(
        File(state.selfiePhotoPath!),
        purpose: 'selfie',
      );
      state = state.copyWith(
        profilePhotoPath: profilePhotoUrl,
        selfiePhotoPath: selfiePhotoUrl,
      );
      await repository.submitForReview(state);
    }
    state = state.copyWith(reviewStatus: ProfileReviewStatus.submitted);
  }

  /// Preview-only helper: skip the manual admin approval step so the demo
  /// build can walk end-to-end to Home. Real production doesn't call this;
  /// approval flips to `approved` when the admin marks it in Supabase.
  void previewApprove() {
    state = state.copyWith(reviewStatus: ProfileReviewStatus.approved);
  }
}

final onboardingDraftProvider =
    NotifierProvider<OnboardingDraftController, OnboardingDraft>(
      OnboardingDraftController.new,
    );
