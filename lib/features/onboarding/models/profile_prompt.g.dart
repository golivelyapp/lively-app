// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_prompt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfilePrompt _$ProfilePromptFromJson(Map<String, dynamic> json) =>
    _ProfilePrompt(
      index: (json['index'] as num).toInt(),
      placeholder: json['placeholder'] as String,
      answer: json['answer'] as String? ?? '',
    );

Map<String, dynamic> _$ProfilePromptToJson(_ProfilePrompt instance) =>
    <String, dynamic>{
      'index': instance.index,
      'placeholder': instance.placeholder,
      'answer': instance.answer,
    };

_SocialLink _$SocialLinkFromJson(Map<String, dynamic> json) => _SocialLink(
  platform: json['platform'] as String,
  handle: json['handle'] as String,
  displayOnProfile: json['displayOnProfile'] as bool? ?? true,
);

Map<String, dynamic> _$SocialLinkToJson(_SocialLink instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'handle': instance.handle,
      'displayOnProfile': instance.displayOnProfile,
    };
