import 'package:freezed_annotation/freezed_annotation.dart';
import 'onboarding_enums.dart';
import 'profile_prompt.dart';

part 'onboarding_draft.freezed.dart';
part 'onboarding_draft.g.dart';

@freezed
abstract class OnboardingDraft with _$OnboardingDraft {
  const factory OnboardingDraft({
    String? name,
    DateTime? dateOfBirth,
    String? company,
    String? profession,
    String? location,
    Gender? gender,
    RelationshipStatus? status,
    String? profilePhotoPath,
    int? heightCm,
    @Default(<String>{}) Set<String> activities,
    @Default(<String>{}) Set<String> traits,
    @Default(<ProfilePrompt>[]) List<ProfilePrompt> musicians,
    @Default(<ProfilePrompt>[]) List<ProfilePrompt> movies,
    @Default(<ProfilePrompt>[]) List<ProfilePrompt> dishes,
    String? bio,
    @Default(<SocialLink>[]) List<SocialLink> socials,
    String? selfiePhotoPath,
    @Default(<String>[]) List<String> additionalPhotoPaths,
    @Default(ProfileReviewStatus.draft) ProfileReviewStatus reviewStatus,
  }) = _OnboardingDraft;

  factory OnboardingDraft.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDraftFromJson(json);
}

extension OnboardingDraftCompletion on OnboardingDraft {
  /// Required onboarding steps in the new short flow — hitting all of
  /// these gets the user to 100%. Optional profile enhancements (height,
  /// traits, musicians, movies, dishes, socials, extra photos) live in
  /// the Profile tab and are not part of this ratio.
  static const int _totalRequiredSections = 5;

  int get completedRequiredCount {
    int count = 0;
    if (name != null &&
        dateOfBirth != null &&
        gender != null &&
        location != null) {
      count++;
    }
    if (profilePhotoPath != null) count++;
    if (activities.isNotEmpty) count++;
    if (bio != null && bio!.isNotEmpty) count++;
    if (selfiePhotoPath != null) count++;
    return count;
  }

  double get completionRatio =>
      completedRequiredCount / _totalRequiredSections;

  /// Canonical section order shown on the Awaiting Review checklist.
  /// Only the required (short-flow) sections show up here now.
  List<MapEntry<String, bool>> get sectionChecklist => <MapEntry<String, bool>>[
    MapEntry<String, bool>(
      'Basics',
      name != null &&
          dateOfBirth != null &&
          gender != null &&
          location != null,
    ),
    MapEntry<String, bool>('Profile Picture', profilePhotoPath != null),
    MapEntry<String, bool>('Activities of Interest', activities.isNotEmpty),
    MapEntry<String, bool>('Bio', bio != null && bio!.isNotEmpty),
    MapEntry<String, bool>('Selfie Verification', selfiePhotoPath != null),
  ];
}
