// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_prompt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfilePrompt {

 int get index; String get placeholder; String get answer;
/// Create a copy of ProfilePrompt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfilePromptCopyWith<ProfilePrompt> get copyWith => _$ProfilePromptCopyWithImpl<ProfilePrompt>(this as ProfilePrompt, _$identity);

  /// Serializes this ProfilePrompt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfilePrompt&&(identical(other.index, index) || other.index == index)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,placeholder,answer);

@override
String toString() {
  return 'ProfilePrompt(index: $index, placeholder: $placeholder, answer: $answer)';
}


}

/// @nodoc
abstract mixin class $ProfilePromptCopyWith<$Res>  {
  factory $ProfilePromptCopyWith(ProfilePrompt value, $Res Function(ProfilePrompt) _then) = _$ProfilePromptCopyWithImpl;
@useResult
$Res call({
 int index, String placeholder, String answer
});




}
/// @nodoc
class _$ProfilePromptCopyWithImpl<$Res>
    implements $ProfilePromptCopyWith<$Res> {
  _$ProfilePromptCopyWithImpl(this._self, this._then);

  final ProfilePrompt _self;
  final $Res Function(ProfilePrompt) _then;

/// Create a copy of ProfilePrompt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? placeholder = null,Object? answer = null,}) {
  return _then(ProfilePrompt(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,placeholder: null == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfilePrompt].
extension ProfilePromptPatterns on ProfilePrompt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfilePrompt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfilePrompt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfilePrompt value)  $default,){
final _that = this;
switch (_that) {
case _ProfilePrompt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfilePrompt value)?  $default,){
final _that = this;
switch (_that) {
case _ProfilePrompt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  String placeholder,  String answer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfilePrompt() when $default != null:
return $default(_that.index,_that.placeholder,_that.answer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  String placeholder,  String answer)  $default,) {final _that = this;
switch (_that) {
case _ProfilePrompt():
return $default(_that.index,_that.placeholder,_that.answer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  String placeholder,  String answer)?  $default,) {final _that = this;
switch (_that) {
case _ProfilePrompt() when $default != null:
return $default(_that.index,_that.placeholder,_that.answer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfilePrompt implements ProfilePrompt {
  const _ProfilePrompt({required this.index, required this.placeholder, this.answer = ''});
  factory _ProfilePrompt.fromJson(Map<String, dynamic> json) => _$ProfilePromptFromJson(json);

@override final  int index;
@override final  String placeholder;
@override@JsonKey() final  String answer;

/// Create a copy of ProfilePrompt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfilePromptCopyWith<_ProfilePrompt> get copyWith => __$ProfilePromptCopyWithImpl<_ProfilePrompt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfilePromptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfilePrompt&&(identical(other.index, index) || other.index == index)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,placeholder,answer);

@override
String toString() {
  return 'ProfilePrompt(index: $index, placeholder: $placeholder, answer: $answer)';
}


}

/// @nodoc
abstract mixin class _$ProfilePromptCopyWith<$Res> implements $ProfilePromptCopyWith<$Res> {
  factory _$ProfilePromptCopyWith(_ProfilePrompt value, $Res Function(_ProfilePrompt) _then) = __$ProfilePromptCopyWithImpl;
@override @useResult
$Res call({
 int index, String placeholder, String answer
});




}
/// @nodoc
class __$ProfilePromptCopyWithImpl<$Res>
    implements _$ProfilePromptCopyWith<$Res> {
  __$ProfilePromptCopyWithImpl(this._self, this._then);

  final _ProfilePrompt _self;
  final $Res Function(_ProfilePrompt) _then;

/// Create a copy of ProfilePrompt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? placeholder = null,Object? answer = null,}) {
  return _then(_ProfilePrompt(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,placeholder: null == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SocialLink {

 String get platform; String get handle; bool get displayOnProfile;
/// Create a copy of SocialLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialLinkCopyWith<SocialLink> get copyWith => _$SocialLinkCopyWithImpl<SocialLink>(this as SocialLink, _$identity);

  /// Serializes this SocialLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialLink&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayOnProfile, displayOnProfile) || other.displayOnProfile == displayOnProfile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,handle,displayOnProfile);

@override
String toString() {
  return 'SocialLink(platform: $platform, handle: $handle, displayOnProfile: $displayOnProfile)';
}


}

/// @nodoc
abstract mixin class $SocialLinkCopyWith<$Res>  {
  factory $SocialLinkCopyWith(SocialLink value, $Res Function(SocialLink) _then) = _$SocialLinkCopyWithImpl;
@useResult
$Res call({
 String platform, String handle, bool displayOnProfile
});




}
/// @nodoc
class _$SocialLinkCopyWithImpl<$Res>
    implements $SocialLinkCopyWith<$Res> {
  _$SocialLinkCopyWithImpl(this._self, this._then);

  final SocialLink _self;
  final $Res Function(SocialLink) _then;

/// Create a copy of SocialLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? handle = null,Object? displayOnProfile = null,}) {
  return _then(SocialLink(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayOnProfile: null == displayOnProfile ? _self.displayOnProfile : displayOnProfile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialLink].
extension SocialLinkPatterns on SocialLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialLink value)  $default,){
final _that = this;
switch (_that) {
case _SocialLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialLink value)?  $default,){
final _that = this;
switch (_that) {
case _SocialLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String platform,  String handle,  bool displayOnProfile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialLink() when $default != null:
return $default(_that.platform,_that.handle,_that.displayOnProfile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String platform,  String handle,  bool displayOnProfile)  $default,) {final _that = this;
switch (_that) {
case _SocialLink():
return $default(_that.platform,_that.handle,_that.displayOnProfile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String platform,  String handle,  bool displayOnProfile)?  $default,) {final _that = this;
switch (_that) {
case _SocialLink() when $default != null:
return $default(_that.platform,_that.handle,_that.displayOnProfile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialLink implements SocialLink {
  const _SocialLink({required this.platform, required this.handle, this.displayOnProfile = true});
  factory _SocialLink.fromJson(Map<String, dynamic> json) => _$SocialLinkFromJson(json);

@override final  String platform;
@override final  String handle;
@override@JsonKey() final  bool displayOnProfile;

/// Create a copy of SocialLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialLinkCopyWith<_SocialLink> get copyWith => __$SocialLinkCopyWithImpl<_SocialLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialLinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialLink&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayOnProfile, displayOnProfile) || other.displayOnProfile == displayOnProfile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,handle,displayOnProfile);

@override
String toString() {
  return 'SocialLink(platform: $platform, handle: $handle, displayOnProfile: $displayOnProfile)';
}


}

/// @nodoc
abstract mixin class _$SocialLinkCopyWith<$Res> implements $SocialLinkCopyWith<$Res> {
  factory _$SocialLinkCopyWith(_SocialLink value, $Res Function(_SocialLink) _then) = __$SocialLinkCopyWithImpl;
@override @useResult
$Res call({
 String platform, String handle, bool displayOnProfile
});




}
/// @nodoc
class __$SocialLinkCopyWithImpl<$Res>
    implements _$SocialLinkCopyWith<$Res> {
  __$SocialLinkCopyWithImpl(this._self, this._then);

  final _SocialLink _self;
  final $Res Function(_SocialLink) _then;

/// Create a copy of SocialLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? handle = null,Object? displayOnProfile = null,}) {
  return _then(_SocialLink(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayOnProfile: null == displayOnProfile ? _self.displayOnProfile : displayOnProfile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
