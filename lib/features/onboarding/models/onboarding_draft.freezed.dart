// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingDraft {

 String? get name; DateTime? get dateOfBirth; String? get company; String? get profession; String? get location; Gender? get gender; RelationshipStatus? get status; String? get profilePhotoPath; int? get heightCm; Set<String> get activities; Set<String> get traits; List<ProfilePrompt> get musicians; List<ProfilePrompt> get movies; List<ProfilePrompt> get dishes; String? get bio; List<SocialLink> get socials; String? get selfiePhotoPath; List<String> get additionalPhotoPaths; ProfileReviewStatus get reviewStatus;
/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingDraftCopyWith<OnboardingDraft> get copyWith => _$OnboardingDraftCopyWithImpl<OnboardingDraft>(this as OnboardingDraft, _$identity);

  /// Serializes this OnboardingDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.company, company) || other.company == company)&&(identical(other.profession, profession) || other.profession == profession)&&(identical(other.location, location) || other.location == location)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.status, status) || other.status == status)&&(identical(other.profilePhotoPath, profilePhotoPath) || other.profilePhotoPath == profilePhotoPath)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&const DeepCollectionEquality().equals(other.activities, activities)&&const DeepCollectionEquality().equals(other.traits, traits)&&const DeepCollectionEquality().equals(other.musicians, musicians)&&const DeepCollectionEquality().equals(other.movies, movies)&&const DeepCollectionEquality().equals(other.dishes, dishes)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.socials, socials)&&(identical(other.selfiePhotoPath, selfiePhotoPath) || other.selfiePhotoPath == selfiePhotoPath)&&const DeepCollectionEquality().equals(other.additionalPhotoPaths, additionalPhotoPaths)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,name,dateOfBirth,company,profession,location,gender,status,profilePhotoPath,heightCm,const DeepCollectionEquality().hash(activities),const DeepCollectionEquality().hash(traits),const DeepCollectionEquality().hash(musicians),const DeepCollectionEquality().hash(movies),const DeepCollectionEquality().hash(dishes),bio,const DeepCollectionEquality().hash(socials),selfiePhotoPath,const DeepCollectionEquality().hash(additionalPhotoPaths),reviewStatus]);

@override
String toString() {
  return 'OnboardingDraft(name: $name, dateOfBirth: $dateOfBirth, company: $company, profession: $profession, location: $location, gender: $gender, status: $status, profilePhotoPath: $profilePhotoPath, heightCm: $heightCm, activities: $activities, traits: $traits, musicians: $musicians, movies: $movies, dishes: $dishes, bio: $bio, socials: $socials, selfiePhotoPath: $selfiePhotoPath, additionalPhotoPaths: $additionalPhotoPaths, reviewStatus: $reviewStatus)';
}


}

/// @nodoc
abstract mixin class $OnboardingDraftCopyWith<$Res>  {
  factory $OnboardingDraftCopyWith(OnboardingDraft value, $Res Function(OnboardingDraft) _then) = _$OnboardingDraftCopyWithImpl;
@useResult
$Res call({
 String? name, DateTime? dateOfBirth, String? company, String? profession, String? location, Gender? gender, RelationshipStatus? status, String? profilePhotoPath, int? heightCm, Set<String> activities, Set<String> traits, List<ProfilePrompt> musicians, List<ProfilePrompt> movies, List<ProfilePrompt> dishes, String? bio, List<SocialLink> socials, String? selfiePhotoPath, List<String> additionalPhotoPaths, ProfileReviewStatus reviewStatus
});




}
/// @nodoc
class _$OnboardingDraftCopyWithImpl<$Res>
    implements $OnboardingDraftCopyWith<$Res> {
  _$OnboardingDraftCopyWithImpl(this._self, this._then);

  final OnboardingDraft _self;
  final $Res Function(OnboardingDraft) _then;

/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? dateOfBirth = freezed,Object? company = freezed,Object? profession = freezed,Object? location = freezed,Object? gender = freezed,Object? status = freezed,Object? profilePhotoPath = freezed,Object? heightCm = freezed,Object? activities = null,Object? traits = null,Object? musicians = null,Object? movies = null,Object? dishes = null,Object? bio = freezed,Object? socials = null,Object? selfiePhotoPath = freezed,Object? additionalPhotoPaths = null,Object? reviewStatus = null,}) {
  return _then(OnboardingDraft(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,profession: freezed == profession ? _self.profession : profession // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RelationshipStatus?,profilePhotoPath: freezed == profilePhotoPath ? _self.profilePhotoPath : profilePhotoPath // ignore: cast_nullable_to_non_nullable
as String?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as int?,activities: null == activities ? _self.activities : activities // ignore: cast_nullable_to_non_nullable
as Set<String>,traits: null == traits ? _self.traits : traits // ignore: cast_nullable_to_non_nullable
as Set<String>,musicians: null == musicians ? _self.musicians : musicians // ignore: cast_nullable_to_non_nullable
as List<ProfilePrompt>,movies: null == movies ? _self.movies : movies // ignore: cast_nullable_to_non_nullable
as List<ProfilePrompt>,dishes: null == dishes ? _self.dishes : dishes // ignore: cast_nullable_to_non_nullable
as List<ProfilePrompt>,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,socials: null == socials ? _self.socials : socials // ignore: cast_nullable_to_non_nullable
as List<SocialLink>,selfiePhotoPath: freezed == selfiePhotoPath ? _self.selfiePhotoPath : selfiePhotoPath // ignore: cast_nullable_to_non_nullable
as String?,additionalPhotoPaths: null == additionalPhotoPaths ? _self.additionalPhotoPaths : additionalPhotoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ProfileReviewStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingDraft].
extension OnboardingDraftPatterns on OnboardingDraft {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingDraft value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingDraft():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingDraft value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  DateTime? dateOfBirth,  String? company,  String? profession,  String? location,  Gender? gender,  RelationshipStatus? status,  String? profilePhotoPath,  int? heightCm,  Set<String> activities,  Set<String> traits,  List<ProfilePrompt> musicians,  List<ProfilePrompt> movies,  List<ProfilePrompt> dishes,  String? bio,  List<SocialLink> socials,  String? selfiePhotoPath,  List<String> additionalPhotoPaths,  ProfileReviewStatus reviewStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
return $default(_that.name,_that.dateOfBirth,_that.company,_that.profession,_that.location,_that.gender,_that.status,_that.profilePhotoPath,_that.heightCm,_that.activities,_that.traits,_that.musicians,_that.movies,_that.dishes,_that.bio,_that.socials,_that.selfiePhotoPath,_that.additionalPhotoPaths,_that.reviewStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  DateTime? dateOfBirth,  String? company,  String? profession,  String? location,  Gender? gender,  RelationshipStatus? status,  String? profilePhotoPath,  int? heightCm,  Set<String> activities,  Set<String> traits,  List<ProfilePrompt> musicians,  List<ProfilePrompt> movies,  List<ProfilePrompt> dishes,  String? bio,  List<SocialLink> socials,  String? selfiePhotoPath,  List<String> additionalPhotoPaths,  ProfileReviewStatus reviewStatus)  $default,) {final _that = this;
switch (_that) {
case _OnboardingDraft():
return $default(_that.name,_that.dateOfBirth,_that.company,_that.profession,_that.location,_that.gender,_that.status,_that.profilePhotoPath,_that.heightCm,_that.activities,_that.traits,_that.musicians,_that.movies,_that.dishes,_that.bio,_that.socials,_that.selfiePhotoPath,_that.additionalPhotoPaths,_that.reviewStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  DateTime? dateOfBirth,  String? company,  String? profession,  String? location,  Gender? gender,  RelationshipStatus? status,  String? profilePhotoPath,  int? heightCm,  Set<String> activities,  Set<String> traits,  List<ProfilePrompt> musicians,  List<ProfilePrompt> movies,  List<ProfilePrompt> dishes,  String? bio,  List<SocialLink> socials,  String? selfiePhotoPath,  List<String> additionalPhotoPaths,  ProfileReviewStatus reviewStatus)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
return $default(_that.name,_that.dateOfBirth,_that.company,_that.profession,_that.location,_that.gender,_that.status,_that.profilePhotoPath,_that.heightCm,_that.activities,_that.traits,_that.musicians,_that.movies,_that.dishes,_that.bio,_that.socials,_that.selfiePhotoPath,_that.additionalPhotoPaths,_that.reviewStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingDraft implements OnboardingDraft {
  const _OnboardingDraft({this.name, this.dateOfBirth, this.company, this.profession, this.location, this.gender, this.status, this.profilePhotoPath, this.heightCm,  Set<String> activities = const <String>{},  Set<String> traits = const <String>{},  List<ProfilePrompt> musicians = const <ProfilePrompt>[],  List<ProfilePrompt> movies = const <ProfilePrompt>[],  List<ProfilePrompt> dishes = const <ProfilePrompt>[], this.bio,  List<SocialLink> socials = const <SocialLink>[], this.selfiePhotoPath,  List<String> additionalPhotoPaths = const <String>[], this.reviewStatus = ProfileReviewStatus.draft}): _activities = activities,_traits = traits,_musicians = musicians,_movies = movies,_dishes = dishes,_socials = socials,_additionalPhotoPaths = additionalPhotoPaths;
  factory _OnboardingDraft.fromJson(Map<String, dynamic> json) => _$OnboardingDraftFromJson(json);

@override final  String? name;
@override final  DateTime? dateOfBirth;
@override final  String? company;
@override final  String? profession;
@override final  String? location;
@override final  Gender? gender;
@override final  RelationshipStatus? status;
@override final  String? profilePhotoPath;
@override final  int? heightCm;
 final  Set<String> _activities;
@override@JsonKey() Set<String> get activities {
  if (_activities is EqualUnmodifiableSetView) return _activities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_activities);
}

 final  Set<String> _traits;
@override@JsonKey() Set<String> get traits {
  if (_traits is EqualUnmodifiableSetView) return _traits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_traits);
}

 final  List<ProfilePrompt> _musicians;
@override@JsonKey() List<ProfilePrompt> get musicians {
  if (_musicians is EqualUnmodifiableListView) return _musicians;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_musicians);
}

 final  List<ProfilePrompt> _movies;
@override@JsonKey() List<ProfilePrompt> get movies {
  if (_movies is EqualUnmodifiableListView) return _movies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_movies);
}

 final  List<ProfilePrompt> _dishes;
@override@JsonKey() List<ProfilePrompt> get dishes {
  if (_dishes is EqualUnmodifiableListView) return _dishes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dishes);
}

@override final  String? bio;
 final  List<SocialLink> _socials;
@override@JsonKey() List<SocialLink> get socials {
  if (_socials is EqualUnmodifiableListView) return _socials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_socials);
}

@override final  String? selfiePhotoPath;
 final  List<String> _additionalPhotoPaths;
@override@JsonKey() List<String> get additionalPhotoPaths {
  if (_additionalPhotoPaths is EqualUnmodifiableListView) return _additionalPhotoPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_additionalPhotoPaths);
}

@override@JsonKey() final  ProfileReviewStatus reviewStatus;

/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingDraftCopyWith<_OnboardingDraft> get copyWith => __$OnboardingDraftCopyWithImpl<_OnboardingDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.company, company) || other.company == company)&&(identical(other.profession, profession) || other.profession == profession)&&(identical(other.location, location) || other.location == location)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.status, status) || other.status == status)&&(identical(other.profilePhotoPath, profilePhotoPath) || other.profilePhotoPath == profilePhotoPath)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&const DeepCollectionEquality().equals(other._activities, _activities)&&const DeepCollectionEquality().equals(other._traits, _traits)&&const DeepCollectionEquality().equals(other._musicians, _musicians)&&const DeepCollectionEquality().equals(other._movies, _movies)&&const DeepCollectionEquality().equals(other._dishes, _dishes)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other._socials, _socials)&&(identical(other.selfiePhotoPath, selfiePhotoPath) || other.selfiePhotoPath == selfiePhotoPath)&&const DeepCollectionEquality().equals(other._additionalPhotoPaths, _additionalPhotoPaths)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,name,dateOfBirth,company,profession,location,gender,status,profilePhotoPath,heightCm,const DeepCollectionEquality().hash(_activities),const DeepCollectionEquality().hash(_traits),const DeepCollectionEquality().hash(_musicians),const DeepCollectionEquality().hash(_movies),const DeepCollectionEquality().hash(_dishes),bio,const DeepCollectionEquality().hash(_socials),selfiePhotoPath,const DeepCollectionEquality().hash(_additionalPhotoPaths),reviewStatus]);

@override
String toString() {
  return 'OnboardingDraft(name: $name, dateOfBirth: $dateOfBirth, company: $company, profession: $profession, location: $location, gender: $gender, status: $status, profilePhotoPath: $profilePhotoPath, heightCm: $heightCm, activities: $activities, traits: $traits, musicians: $musicians, movies: $movies, dishes: $dishes, bio: $bio, socials: $socials, selfiePhotoPath: $selfiePhotoPath, additionalPhotoPaths: $additionalPhotoPaths, reviewStatus: $reviewStatus)';
}


}

/// @nodoc
abstract mixin class _$OnboardingDraftCopyWith<$Res> implements $OnboardingDraftCopyWith<$Res> {
  factory _$OnboardingDraftCopyWith(_OnboardingDraft value, $Res Function(_OnboardingDraft) _then) = __$OnboardingDraftCopyWithImpl;
@override @useResult
$Res call({
 String? name, DateTime? dateOfBirth, String? company, String? profession, String? location, Gender? gender, RelationshipStatus? status, String? profilePhotoPath, int? heightCm, Set<String> activities, Set<String> traits, List<ProfilePrompt> musicians, List<ProfilePrompt> movies, List<ProfilePrompt> dishes, String? bio, List<SocialLink> socials, String? selfiePhotoPath, List<String> additionalPhotoPaths, ProfileReviewStatus reviewStatus
});




}
/// @nodoc
class __$OnboardingDraftCopyWithImpl<$Res>
    implements _$OnboardingDraftCopyWith<$Res> {
  __$OnboardingDraftCopyWithImpl(this._self, this._then);

  final _OnboardingDraft _self;
  final $Res Function(_OnboardingDraft) _then;

/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? dateOfBirth = freezed,Object? company = freezed,Object? profession = freezed,Object? location = freezed,Object? gender = freezed,Object? status = freezed,Object? profilePhotoPath = freezed,Object? heightCm = freezed,Object? activities = null,Object? traits = null,Object? musicians = null,Object? movies = null,Object? dishes = null,Object? bio = freezed,Object? socials = null,Object? selfiePhotoPath = freezed,Object? additionalPhotoPaths = null,Object? reviewStatus = null,}) {
  return _then(_OnboardingDraft(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,profession: freezed == profession ? _self.profession : profession // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RelationshipStatus?,profilePhotoPath: freezed == profilePhotoPath ? _self.profilePhotoPath : profilePhotoPath // ignore: cast_nullable_to_non_nullable
as String?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as int?,activities: null == activities ? _self._activities : activities // ignore: cast_nullable_to_non_nullable
as Set<String>,traits: null == traits ? _self._traits : traits // ignore: cast_nullable_to_non_nullable
as Set<String>,musicians: null == musicians ? _self._musicians : musicians // ignore: cast_nullable_to_non_nullable
as List<ProfilePrompt>,movies: null == movies ? _self._movies : movies // ignore: cast_nullable_to_non_nullable
as List<ProfilePrompt>,dishes: null == dishes ? _self._dishes : dishes // ignore: cast_nullable_to_non_nullable
as List<ProfilePrompt>,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,socials: null == socials ? _self._socials : socials // ignore: cast_nullable_to_non_nullable
as List<SocialLink>,selfiePhotoPath: freezed == selfiePhotoPath ? _self.selfiePhotoPath : selfiePhotoPath // ignore: cast_nullable_to_non_nullable
as String?,additionalPhotoPaths: null == additionalPhotoPaths ? _self._additionalPhotoPaths : additionalPhotoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ProfileReviewStatus,
  ));
}


}

// dart format on
