import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_prompt.freezed.dart';
part 'profile_prompt.g.dart';

/// One numbered free-text answer in a prompt set (e.g. Favourite Musicians
/// entry 3 of 5). [placeholder] is the ghost-text example shown before the
/// user types, never submitted as real content.
@freezed
abstract class ProfilePrompt with _$ProfilePrompt {
  const factory ProfilePrompt({
    required int index,
    required String placeholder,
    @Default('') String answer,
  }) = _ProfilePrompt;

  factory ProfilePrompt.fromJson(Map<String, dynamic> json) =>
      _$ProfilePromptFromJson(json);
}

@freezed
abstract class SocialLink with _$SocialLink {
  const factory SocialLink({
    required String platform,
    required String handle,
    @Default(true) bool displayOnProfile,
  }) = _SocialLink;

  factory SocialLink.fromJson(Map<String, dynamic> json) =>
      _$SocialLinkFromJson(json);
}
