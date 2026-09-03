// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Event {

 String get id; String get title; String get coverImageUrl; EventCategory get category; String get hostId; String get hostName; String get hostPhotoUrl; bool get hostVerified; String get hostBio; int get hostEventsHosted; double get hostRating; DateTime get startTime; int get durationMinutes; String get venueName; String get venueAddress; String get neighbourhood; int get priceRupees; int get totalSpots; int get maleRsvpCount; int get femaleRsvpCount; List<String> get attendeeAvatarUrls; String get description; EventGenderPolicy get genderPolicy; bool get isGoing; int? get priceRupeesWomen; int? get priceRupeesMen;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.hostPhotoUrl, hostPhotoUrl) || other.hostPhotoUrl == hostPhotoUrl)&&(identical(other.hostVerified, hostVerified) || other.hostVerified == hostVerified)&&(identical(other.hostBio, hostBio) || other.hostBio == hostBio)&&(identical(other.hostEventsHosted, hostEventsHosted) || other.hostEventsHosted == hostEventsHosted)&&(identical(other.hostRating, hostRating) || other.hostRating == hostRating)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.venueAddress, venueAddress) || other.venueAddress == venueAddress)&&(identical(other.neighbourhood, neighbourhood) || other.neighbourhood == neighbourhood)&&(identical(other.priceRupees, priceRupees) || other.priceRupees == priceRupees)&&(identical(other.totalSpots, totalSpots) || other.totalSpots == totalSpots)&&(identical(other.maleRsvpCount, maleRsvpCount) || other.maleRsvpCount == maleRsvpCount)&&(identical(other.femaleRsvpCount, femaleRsvpCount) || other.femaleRsvpCount == femaleRsvpCount)&&const DeepCollectionEquality().equals(other.attendeeAvatarUrls, attendeeAvatarUrls)&&(identical(other.description, description) || other.description == description)&&(identical(other.genderPolicy, genderPolicy) || other.genderPolicy == genderPolicy)&&(identical(other.isGoing, isGoing) || other.isGoing == isGoing)&&(identical(other.priceRupeesWomen, priceRupeesWomen) || other.priceRupeesWomen == priceRupeesWomen)&&(identical(other.priceRupeesMen, priceRupeesMen) || other.priceRupeesMen == priceRupeesMen));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,title,coverImageUrl,category,hostId,hostName,hostPhotoUrl,hostVerified,hostBio,hostEventsHosted,hostRating,startTime,durationMinutes,venueName,venueAddress,neighbourhood,priceRupees,totalSpots,maleRsvpCount,femaleRsvpCount,const DeepCollectionEquality().hash(attendeeAvatarUrls),description,genderPolicy,isGoing,priceRupeesWomen,priceRupeesMen]);

@override
String toString() {
  return 'Event(id: $id, title: $title, coverImageUrl: $coverImageUrl, category: $category, hostId: $hostId, hostName: $hostName, hostPhotoUrl: $hostPhotoUrl, hostVerified: $hostVerified, hostBio: $hostBio, hostEventsHosted: $hostEventsHosted, hostRating: $hostRating, startTime: $startTime, durationMinutes: $durationMinutes, venueName: $venueName, venueAddress: $venueAddress, neighbourhood: $neighbourhood, priceRupees: $priceRupees, totalSpots: $totalSpots, maleRsvpCount: $maleRsvpCount, femaleRsvpCount: $femaleRsvpCount, attendeeAvatarUrls: $attendeeAvatarUrls, description: $description, genderPolicy: $genderPolicy, isGoing: $isGoing, priceRupeesWomen: $priceRupeesWomen, priceRupeesMen: $priceRupeesMen)';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String coverImageUrl, EventCategory category, String hostId, String hostName, String hostPhotoUrl, bool hostVerified, String hostBio, int hostEventsHosted, double hostRating, DateTime startTime, int durationMinutes, String venueName, String venueAddress, String neighbourhood, int priceRupees, int totalSpots, int maleRsvpCount, int femaleRsvpCount, List<String> attendeeAvatarUrls, String description, EventGenderPolicy genderPolicy, bool isGoing, int? priceRupeesWomen, int? priceRupeesMen
});




}
/// @nodoc
class _$EventCopyWithImpl<$Res>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? coverImageUrl = null,Object? category = null,Object? hostId = null,Object? hostName = null,Object? hostPhotoUrl = null,Object? hostVerified = null,Object? hostBio = null,Object? hostEventsHosted = null,Object? hostRating = null,Object? startTime = null,Object? durationMinutes = null,Object? venueName = null,Object? venueAddress = null,Object? neighbourhood = null,Object? priceRupees = null,Object? totalSpots = null,Object? maleRsvpCount = null,Object? femaleRsvpCount = null,Object? attendeeAvatarUrls = null,Object? description = null,Object? genderPolicy = null,Object? isGoing = null,Object? priceRupeesWomen = freezed,Object? priceRupeesMen = freezed,}) {
  return _then(Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as EventCategory,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,hostPhotoUrl: null == hostPhotoUrl ? _self.hostPhotoUrl : hostPhotoUrl // ignore: cast_nullable_to_non_nullable
as String,hostVerified: null == hostVerified ? _self.hostVerified : hostVerified // ignore: cast_nullable_to_non_nullable
as bool,hostBio: null == hostBio ? _self.hostBio : hostBio // ignore: cast_nullable_to_non_nullable
as String,hostEventsHosted: null == hostEventsHosted ? _self.hostEventsHosted : hostEventsHosted // ignore: cast_nullable_to_non_nullable
as int,hostRating: null == hostRating ? _self.hostRating : hostRating // ignore: cast_nullable_to_non_nullable
as double,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,venueAddress: null == venueAddress ? _self.venueAddress : venueAddress // ignore: cast_nullable_to_non_nullable
as String,neighbourhood: null == neighbourhood ? _self.neighbourhood : neighbourhood // ignore: cast_nullable_to_non_nullable
as String,priceRupees: null == priceRupees ? _self.priceRupees : priceRupees // ignore: cast_nullable_to_non_nullable
as int,totalSpots: null == totalSpots ? _self.totalSpots : totalSpots // ignore: cast_nullable_to_non_nullable
as int,maleRsvpCount: null == maleRsvpCount ? _self.maleRsvpCount : maleRsvpCount // ignore: cast_nullable_to_non_nullable
as int,femaleRsvpCount: null == femaleRsvpCount ? _self.femaleRsvpCount : femaleRsvpCount // ignore: cast_nullable_to_non_nullable
as int,attendeeAvatarUrls: null == attendeeAvatarUrls ? _self.attendeeAvatarUrls : attendeeAvatarUrls // ignore: cast_nullable_to_non_nullable
as List<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,genderPolicy: null == genderPolicy ? _self.genderPolicy : genderPolicy // ignore: cast_nullable_to_non_nullable
as EventGenderPolicy,isGoing: null == isGoing ? _self.isGoing : isGoing // ignore: cast_nullable_to_non_nullable
as bool,priceRupeesWomen: freezed == priceRupeesWomen ? _self.priceRupeesWomen : priceRupeesWomen // ignore: cast_nullable_to_non_nullable
as int?,priceRupeesMen: freezed == priceRupeesMen ? _self.priceRupeesMen : priceRupeesMen // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Event value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Event value)  $default,){
final _that = this;
switch (_that) {
case _Event():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Event value)?  $default,){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String coverImageUrl,  EventCategory category,  String hostId,  String hostName,  String hostPhotoUrl,  bool hostVerified,  String hostBio,  int hostEventsHosted,  double hostRating,  DateTime startTime,  int durationMinutes,  String venueName,  String venueAddress,  String neighbourhood,  int priceRupees,  int totalSpots,  int maleRsvpCount,  int femaleRsvpCount,  List<String> attendeeAvatarUrls,  String description,  EventGenderPolicy genderPolicy,  bool isGoing,  int? priceRupeesWomen,  int? priceRupeesMen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.coverImageUrl,_that.category,_that.hostId,_that.hostName,_that.hostPhotoUrl,_that.hostVerified,_that.hostBio,_that.hostEventsHosted,_that.hostRating,_that.startTime,_that.durationMinutes,_that.venueName,_that.venueAddress,_that.neighbourhood,_that.priceRupees,_that.totalSpots,_that.maleRsvpCount,_that.femaleRsvpCount,_that.attendeeAvatarUrls,_that.description,_that.genderPolicy,_that.isGoing,_that.priceRupeesWomen,_that.priceRupeesMen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String coverImageUrl,  EventCategory category,  String hostId,  String hostName,  String hostPhotoUrl,  bool hostVerified,  String hostBio,  int hostEventsHosted,  double hostRating,  DateTime startTime,  int durationMinutes,  String venueName,  String venueAddress,  String neighbourhood,  int priceRupees,  int totalSpots,  int maleRsvpCount,  int femaleRsvpCount,  List<String> attendeeAvatarUrls,  String description,  EventGenderPolicy genderPolicy,  bool isGoing,  int? priceRupeesWomen,  int? priceRupeesMen)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.title,_that.coverImageUrl,_that.category,_that.hostId,_that.hostName,_that.hostPhotoUrl,_that.hostVerified,_that.hostBio,_that.hostEventsHosted,_that.hostRating,_that.startTime,_that.durationMinutes,_that.venueName,_that.venueAddress,_that.neighbourhood,_that.priceRupees,_that.totalSpots,_that.maleRsvpCount,_that.femaleRsvpCount,_that.attendeeAvatarUrls,_that.description,_that.genderPolicy,_that.isGoing,_that.priceRupeesWomen,_that.priceRupeesMen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String coverImageUrl,  EventCategory category,  String hostId,  String hostName,  String hostPhotoUrl,  bool hostVerified,  String hostBio,  int hostEventsHosted,  double hostRating,  DateTime startTime,  int durationMinutes,  String venueName,  String venueAddress,  String neighbourhood,  int priceRupees,  int totalSpots,  int maleRsvpCount,  int femaleRsvpCount,  List<String> attendeeAvatarUrls,  String description,  EventGenderPolicy genderPolicy,  bool isGoing,  int? priceRupeesWomen,  int? priceRupeesMen)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.title,_that.coverImageUrl,_that.category,_that.hostId,_that.hostName,_that.hostPhotoUrl,_that.hostVerified,_that.hostBio,_that.hostEventsHosted,_that.hostRating,_that.startTime,_that.durationMinutes,_that.venueName,_that.venueAddress,_that.neighbourhood,_that.priceRupees,_that.totalSpots,_that.maleRsvpCount,_that.femaleRsvpCount,_that.attendeeAvatarUrls,_that.description,_that.genderPolicy,_that.isGoing,_that.priceRupeesWomen,_that.priceRupeesMen);case _:
  return null;

}
}

}

/// @nodoc


class _Event extends Event {
  const _Event({required this.id, required this.title, required this.coverImageUrl, required this.category, required this.hostId, required this.hostName, required this.hostPhotoUrl, required this.hostVerified, required this.hostBio, required this.hostEventsHosted, required this.hostRating, required this.startTime, required this.durationMinutes, required this.venueName, required this.venueAddress, required this.neighbourhood, required this.priceRupees, required this.totalSpots, required this.maleRsvpCount, required this.femaleRsvpCount, required  List<String> attendeeAvatarUrls, required this.description, this.genderPolicy = EventGenderPolicy.everyone, this.isGoing = false, this.priceRupeesWomen, this.priceRupeesMen}): _attendeeAvatarUrls = attendeeAvatarUrls,super._();
  

@override final  String id;
@override final  String title;
@override final  String coverImageUrl;
@override final  EventCategory category;
@override final  String hostId;
@override final  String hostName;
@override final  String hostPhotoUrl;
@override final  bool hostVerified;
@override final  String hostBio;
@override final  int hostEventsHosted;
@override final  double hostRating;
@override final  DateTime startTime;
@override final  int durationMinutes;
@override final  String venueName;
@override final  String venueAddress;
@override final  String neighbourhood;
@override final  int priceRupees;
@override final  int totalSpots;
@override final  int maleRsvpCount;
@override final  int femaleRsvpCount;
 final  List<String> _attendeeAvatarUrls;
@override List<String> get attendeeAvatarUrls {
  if (_attendeeAvatarUrls is EqualUnmodifiableListView) return _attendeeAvatarUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attendeeAvatarUrls);
}

@override final  String description;
@override@JsonKey() final  EventGenderPolicy genderPolicy;
@override@JsonKey() final  bool isGoing;
@override final  int? priceRupeesWomen;
@override final  int? priceRupeesMen;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCopyWith<_Event> get copyWith => __$EventCopyWithImpl<_Event>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.hostPhotoUrl, hostPhotoUrl) || other.hostPhotoUrl == hostPhotoUrl)&&(identical(other.hostVerified, hostVerified) || other.hostVerified == hostVerified)&&(identical(other.hostBio, hostBio) || other.hostBio == hostBio)&&(identical(other.hostEventsHosted, hostEventsHosted) || other.hostEventsHosted == hostEventsHosted)&&(identical(other.hostRating, hostRating) || other.hostRating == hostRating)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.venueAddress, venueAddress) || other.venueAddress == venueAddress)&&(identical(other.neighbourhood, neighbourhood) || other.neighbourhood == neighbourhood)&&(identical(other.priceRupees, priceRupees) || other.priceRupees == priceRupees)&&(identical(other.totalSpots, totalSpots) || other.totalSpots == totalSpots)&&(identical(other.maleRsvpCount, maleRsvpCount) || other.maleRsvpCount == maleRsvpCount)&&(identical(other.femaleRsvpCount, femaleRsvpCount) || other.femaleRsvpCount == femaleRsvpCount)&&const DeepCollectionEquality().equals(other._attendeeAvatarUrls, _attendeeAvatarUrls)&&(identical(other.description, description) || other.description == description)&&(identical(other.genderPolicy, genderPolicy) || other.genderPolicy == genderPolicy)&&(identical(other.isGoing, isGoing) || other.isGoing == isGoing)&&(identical(other.priceRupeesWomen, priceRupeesWomen) || other.priceRupeesWomen == priceRupeesWomen)&&(identical(other.priceRupeesMen, priceRupeesMen) || other.priceRupeesMen == priceRupeesMen));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,title,coverImageUrl,category,hostId,hostName,hostPhotoUrl,hostVerified,hostBio,hostEventsHosted,hostRating,startTime,durationMinutes,venueName,venueAddress,neighbourhood,priceRupees,totalSpots,maleRsvpCount,femaleRsvpCount,const DeepCollectionEquality().hash(_attendeeAvatarUrls),description,genderPolicy,isGoing,priceRupeesWomen,priceRupeesMen]);

@override
String toString() {
  return 'Event(id: $id, title: $title, coverImageUrl: $coverImageUrl, category: $category, hostId: $hostId, hostName: $hostName, hostPhotoUrl: $hostPhotoUrl, hostVerified: $hostVerified, hostBio: $hostBio, hostEventsHosted: $hostEventsHosted, hostRating: $hostRating, startTime: $startTime, durationMinutes: $durationMinutes, venueName: $venueName, venueAddress: $venueAddress, neighbourhood: $neighbourhood, priceRupees: $priceRupees, totalSpots: $totalSpots, maleRsvpCount: $maleRsvpCount, femaleRsvpCount: $femaleRsvpCount, attendeeAvatarUrls: $attendeeAvatarUrls, description: $description, genderPolicy: $genderPolicy, isGoing: $isGoing, priceRupeesWomen: $priceRupeesWomen, priceRupeesMen: $priceRupeesMen)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String coverImageUrl, EventCategory category, String hostId, String hostName, String hostPhotoUrl, bool hostVerified, String hostBio, int hostEventsHosted, double hostRating, DateTime startTime, int durationMinutes, String venueName, String venueAddress, String neighbourhood, int priceRupees, int totalSpots, int maleRsvpCount, int femaleRsvpCount, List<String> attendeeAvatarUrls, String description, EventGenderPolicy genderPolicy, bool isGoing, int? priceRupeesWomen, int? priceRupeesMen
});




}
/// @nodoc
class __$EventCopyWithImpl<$Res>
    implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? coverImageUrl = null,Object? category = null,Object? hostId = null,Object? hostName = null,Object? hostPhotoUrl = null,Object? hostVerified = null,Object? hostBio = null,Object? hostEventsHosted = null,Object? hostRating = null,Object? startTime = null,Object? durationMinutes = null,Object? venueName = null,Object? venueAddress = null,Object? neighbourhood = null,Object? priceRupees = null,Object? totalSpots = null,Object? maleRsvpCount = null,Object? femaleRsvpCount = null,Object? attendeeAvatarUrls = null,Object? description = null,Object? genderPolicy = null,Object? isGoing = null,Object? priceRupeesWomen = freezed,Object? priceRupeesMen = freezed,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverImageUrl: null == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as EventCategory,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,hostPhotoUrl: null == hostPhotoUrl ? _self.hostPhotoUrl : hostPhotoUrl // ignore: cast_nullable_to_non_nullable
as String,hostVerified: null == hostVerified ? _self.hostVerified : hostVerified // ignore: cast_nullable_to_non_nullable
as bool,hostBio: null == hostBio ? _self.hostBio : hostBio // ignore: cast_nullable_to_non_nullable
as String,hostEventsHosted: null == hostEventsHosted ? _self.hostEventsHosted : hostEventsHosted // ignore: cast_nullable_to_non_nullable
as int,hostRating: null == hostRating ? _self.hostRating : hostRating // ignore: cast_nullable_to_non_nullable
as double,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,venueAddress: null == venueAddress ? _self.venueAddress : venueAddress // ignore: cast_nullable_to_non_nullable
as String,neighbourhood: null == neighbourhood ? _self.neighbourhood : neighbourhood // ignore: cast_nullable_to_non_nullable
as String,priceRupees: null == priceRupees ? _self.priceRupees : priceRupees // ignore: cast_nullable_to_non_nullable
as int,totalSpots: null == totalSpots ? _self.totalSpots : totalSpots // ignore: cast_nullable_to_non_nullable
as int,maleRsvpCount: null == maleRsvpCount ? _self.maleRsvpCount : maleRsvpCount // ignore: cast_nullable_to_non_nullable
as int,femaleRsvpCount: null == femaleRsvpCount ? _self.femaleRsvpCount : femaleRsvpCount // ignore: cast_nullable_to_non_nullable
as int,attendeeAvatarUrls: null == attendeeAvatarUrls ? _self._attendeeAvatarUrls : attendeeAvatarUrls // ignore: cast_nullable_to_non_nullable
as List<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,genderPolicy: null == genderPolicy ? _self.genderPolicy : genderPolicy // ignore: cast_nullable_to_non_nullable
as EventGenderPolicy,isGoing: null == isGoing ? _self.isGoing : isGoing // ignore: cast_nullable_to_non_nullable
as bool,priceRupeesWomen: freezed == priceRupeesWomen ? _self.priceRupeesWomen : priceRupeesWomen // ignore: cast_nullable_to_non_nullable
as int?,priceRupeesMen: freezed == priceRupeesMen ? _self.priceRupeesMen : priceRupeesMen // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
