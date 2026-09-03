import 'package:freezed_annotation/freezed_annotation.dart';
import '../../onboarding/models/onboarding_enums.dart';
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
    // Per-gender pricing. When null, `priceRupees` applies to both.
    // A value of 0 means Free for that gender.
    int? priceRupeesWomen,
    int? priceRupeesMen,
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

  // --- Per-gender pricing -----------------------------------------------

  int get _priceWomen => priceRupeesWomen ?? priceRupees;
  int get _priceMen => priceRupeesMen ?? priceRupees;

  /// Ticket price for the viewer's gender. Falls back to the general
  /// `priceRupees` when the viewer's gender is not known or is "other".
  int priceFor(Gender? gender) => switch (gender) {
    Gender.female => _priceWomen,
    Gender.male => _priceMen,
    _ => priceRupees,
  };

  bool isFreeFor(Gender? gender) => priceFor(gender) == 0;

  /// Intelligent global label, no viewer context:
  ///   "Free"                          – both free
  ///   "₹299"                          – same price for both
  ///   "₹199 (W) · ₹399 (M)"           – different paid amounts
  ///   "Free for women · ₹399 for men" – mixed
  String get priceLabel {
    final int w = _priceWomen;
    final int m = _priceMen;
    if (w == 0 && m == 0) return 'Free';
    if (w == m) return '₹$w';
    if (w == 0) return 'Free for women · ₹$m for men';
    if (m == 0) return 'Free for men · ₹$w for women';
    return '₹$w (W) · ₹$m (M)';
  }

  /// Viewer-gender specific label used in RSVP CTA / bottom bar.
  String priceLabelFor(Gender? gender) {
    final int p = priceFor(gender);
    return p == 0 ? 'Free' : '₹$p';
  }
}
