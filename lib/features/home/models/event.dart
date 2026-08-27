import 'package:freezed_annotation/freezed_annotation.dart';
import 'event_category.dart';

part 'event.freezed.dart';

enum EventGenderPolicy { everyone, womenOnly, menOnly }

@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    required String title,
    required String coverImageUrl,
    required EventCategory category,
    required String hostId,
    required String hostName,
    required String hostPhotoUrl,
    required bool hostVerified,
    required String hostBio,
    required int hostEventsHosted,
    required double hostRating,
    required DateTime startTime,
    required int durationMinutes,
    required String venueName,
    required String venueAddress,
    required String neighbourhood,
    required int priceRupees,
    required int totalSpots,
    required int maleRsvpCount,
    required int femaleRsvpCount,
    required List<String> attendeeAvatarUrls,
    required String description,
    @Default(EventGenderPolicy.everyone) EventGenderPolicy genderPolicy,
    @Default(false) bool isGoing,
  }) = _Event;

  const Event._();

  int get rsvpCount => maleRsvpCount + femaleRsvpCount;

  int get spotsRemaining => totalSpots - rsvpCount;

  double get maleRatio => rsvpCount == 0 ? 0.5 : maleRsvpCount / rsvpCount;

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  bool get isPast => DateTime.now().isAfter(endTime);

  bool get isWithinPostEventWindow =>
      isPast && DateTime.now().isBefore(endTime.add(const Duration(hours: 48)));

  bool get isFree => priceRupees == 0;

  bool get isWomenOnly => genderPolicy == EventGenderPolicy.womenOnly;

  bool get isMenOnly => genderPolicy == EventGenderPolicy.menOnly;

  bool get isFull => spotsRemaining <= 0;

  bool get isLowOnSpots => spotsRemaining > 0 && spotsRemaining <= 5;
}
