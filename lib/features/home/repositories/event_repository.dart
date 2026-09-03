import 'dart:io';
import '../models/event.dart';
import '../models/event_category.dart';

abstract class EventRepository {
  /// Fetch published, upcoming events + attach the current user's RSVP
  /// state so `Event.isGoing` reflects reality.
  Future<List<Event>> fetchEvents();

  /// Insert a new RSVP row for the current user on this event.
  /// Returns the fresh Event with `isGoing = true`.
  Future<void> rsvp(String eventId);

  /// Mark the current user's RSVP as cancelled.
  Future<void> cancelRsvp(String eventId);

  /// Uploads a cover image and inserts a fresh event row. Returns the
  /// newly-inserted Event (already mapped from the DB row).
  Future<Event> createEvent({
    required String title,
    required String description,
    required EventCategory category,
    required DateTime startTime,
    required int durationMinutes,
    required String venueName,
    required String venueAddress,
    required int totalSpots,
    required int priceRupees,
    required int priceRupeesWomen,
    required int priceRupeesMen,
    required File coverImage,
  });
}
