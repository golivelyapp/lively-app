// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingDraft _$OnboardingDraftFromJson(
  Map<String, dynamic> json,
) => _OnboardingDraft(
  name: json['name'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  company: json['company'] as String?,
  profession: json['profession'] as String?,
  location: json['location'] as String?,
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  status: $enumDecodeNullable(_$RelationshipStatusEnumMap, json['status']),
  profilePhotoPath: json['profilePhotoPath'] as String?,
  heightCm: (json['heightCm'] as num?)?.toInt(),
  activities:
      (json['activities'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const <String>{},
  traits:
      (json['traits'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const <String>{},
  musicians:
      (json['musicians'] as List<dynamic>?)
          ?.map((e) => ProfilePrompt.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ProfilePrompt>[],
  movies:
      (json['movies'] as List<dynamic>?)
          ?.map((e) => ProfilePrompt.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ProfilePrompt>[],
  dishes:
      (json['dishes'] as List<dynamic>?)
          ?.map((e) => ProfilePrompt.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ProfilePrompt>[],
  bio: json['bio'] as String?,
  socials:
      (json['socials'] as List<dynamic>?)
          ?.map((e) => SocialLink.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SocialLink>[],
  selfiePhotoPath: json['selfiePhotoPath'] as String?,
  additionalPhotoPaths:
      (json['additionalPhotoPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  reviewStatus:
      $enumDecodeNullable(_$ProfileReviewStatusEnumMap, json['reviewStatus']) ??
      ProfileReviewStatus.draft,
);

Map<String, dynamic> _$OnboardingDraftToJson(_OnboardingDraft instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'company': instance.company,
      'profession': instance.profession,
      'location': instance.location,
      'gender': _$GenderEnumMap[instance.gender],
      'status': _$RelationshipStatusEnumMap[instance.status],
      'profilePhotoPath': instance.profilePhotoPath,
      'heightCm': instance.heightCm,
      'activities': instance.activities.toList(),
      'traits': instance.traits.toList(),
      'musicians': instance.musicians,
      'movies': instance.movies,
      'dishes': instance.dishes,
      'bio': instance.bio,
      'socials': instance.socials,
      'selfiePhotoPath': instance.selfiePhotoPath,
      'additionalPhotoPaths': instance.additionalPhotoPaths,
      'reviewStatus': _$ProfileReviewStatusEnumMap[instance.reviewStatus]!,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

const _$RelationshipStatusEnumMap = {
  RelationshipStatus.single: 'single',
  RelationshipStatus.married: 'married',
  RelationshipStatus.inRelationship: 'inRelationship',
};

const _$ProfileReviewStatusEnumMap = {
  ProfileReviewStatus.draft: 'draft',
  ProfileReviewStatus.submitted: 'submitted',
  ProfileReviewStatus.underReview: 'underReview',
  ProfileReviewStatus.approved: 'approved',
  ProfileReviewStatus.rejected: 'rejected',
};
