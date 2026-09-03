import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/supabase_client.dart';
import '../models/event.dart';
import '../models/event_category.dart';
import 'event_repository.dart';

/// Reads events from Supabase + joins them with the current user's rsvps
/// so `Event.isGoing` reflects the DB, not local state.
class SupabaseEventRepository implements EventRepository {
  const SupabaseEventRepository();

  SupabaseClient get _c => SupabaseService.client;

  @override
  Future<List<Event>> fetchEvents() async {
    // Fetch events + the activity_categories row inline so we can map
    // the DB category_id to our client-side EventCategory enum.
    final List<Map<String, dynamic>> eventRows =
        List<Map<String, dynamic>>.from(
      await _c
          .from('events')
          .select('''
            *,
            category:activity_categories!inner(code)
          ''')
          .eq('is_published', true)
          .isFilter('cancelled_at', null)
          .isFilter('deleted_at', null)
          .order('start_time'),
    );

    // Fetch the current user's active RSVPs in one shot; merge in Dart.
    final String? uid = _c.auth.currentUser?.id;
    final Set<String> myRsvpEventIds = <String>{};
    if (uid != null) {
      final List<Map<String, dynamic>> myRsvps =
          List<Map<String, dynamic>>.from(
        await _c
            .from('rsvps')
            .select('event_id')
            .eq('profile_id', uid)
            .isFilter('cancelled_at', null),
      );
      for (final row in myRsvps) {
        myRsvpEventIds.add(row['event_id'] as String);
      }
    }

    return eventRows.map((row) => _rowToEvent(row, myRsvpEventIds)).toList();
  }

  @override
  Future<void> rsvp(String eventId) async {
    final String uid = _c.auth.currentUser!.id;
    // Upsert-on-conflict logic: if a previously cancelled rsvp exists
    // for this (event, profile), un-cancel it. Otherwise insert fresh.
    final existing = await _c
        .from('rsvps')
        .select('id, cancelled_at')
        .eq('event_id', eventId)
        .eq('profile_id', uid)
        .maybeSingle();
    if (existing == null) {
      await _c.from('rsvps').insert({
        'event_id': eventId,
        'profile_id': uid,
      });
    } else if (existing['cancelled_at'] != null) {
      await _c
          .from('rsvps')
          .update({'cancelled_at': null})
          .eq('id', existing['id'] as Object);
    }
    // If already active (existing != null and cancelled_at is null), no-op.
  }

  @override
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
  }) async {
    final String uid = _c.auth.currentUser!.id;

    // 1) Look up the category id from its code.
    final Map<String, dynamic> catRow = await _c
        .from('activity_categories')
        .select('id')
        .eq('code', _categoryToCode(category))
        .single();
    final String categoryId = catRow['id'] as String;

    // 2) Look up the default city (Bengaluru).
    final Map<String, dynamic> cityRow = await _c
        .from('cities')
        .select('id')
        .eq('code', 'bengaluru')
        .single();
    final String cityId = cityRow['id'] as String;

    // 3) Upload the cover to `event_covers/<uid>/<epoch>_cover.<ext>`.
    //    Path first segment must equal auth.uid() to satisfy storage RLS.
    if (!await coverImage.exists()) {
      throw StateError('Cover image no longer exists on device.');
    }
    final String extRaw = coverImage.path.split('.').last.toLowerCase();
    final String ext = switch (extRaw) {
      'jpeg' => 'jpg',
      'heic' || 'heif' => 'jpg',
      _ => extRaw,
    };
    final String storagePath =
        '$uid/${DateTime.now().millisecondsSinceEpoch}_cover.$ext';
    try {
      await _c.storage.from('event_covers').upload(
            storagePath,
            coverImage,
            fileOptions: FileOptions(
              contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}',
              upsert: false,
            ),
          );
    } on StorageException catch (e) {
      throw Exception('Cover upload failed: ${e.message}');
    }
    final String coverUrl =
        _c.storage.from('event_covers').getPublicUrl(storagePath);

    // 4) Insert the events row and read it back.
    final String neighbourhood =
        venueAddress.contains(',') ? venueAddress.split(',').last.trim() : '';

    final Map<String, dynamic> inserted;
    try {
      inserted = await _c
          .from('events')
          .insert({
            'host_id': uid,
            'title': title,
            'description': description,
            'category_id': categoryId,
            'city_id': cityId,
            'venue_name': venueName,
            'venue_address': venueAddress,
            'neighbourhood': neighbourhood,
            'start_time': startTime.toUtc().toIso8601String(),
            'duration_minutes': durationMinutes,
            'total_spots': totalSpots,
            'price_rupees': priceRupees,
            'price_rupees_women': priceRupeesWomen,
            'price_rupees_men': priceRupeesMen,
            'cover_image_url': coverUrl,
            'is_published': true,
            'published_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select('''
            *,
            category:activity_categories!inner(code)
          ''')
          .single();
    } on PostgrestException catch (e) {
      // Clean up the orphaned cover so retries don't collide.
      try {
        await _c.storage.from('event_covers').remove(<String>[storagePath]);
      } catch (_) {}
      throw Exception('Event insert failed: ${e.message}');
    }

    return _rowToEvent(inserted, <String>{});
  }

  static String _categoryToCode(EventCategory c) => switch (c) {
    EventCategory.art => 'art',
    EventCategory.sports => 'sports',
    EventCategory.foodAndDrinks => 'food_and_drinks',
    EventCategory.outdoors => 'outdoors',
    EventCategory.music => 'music',
    EventCategory.boardGames => 'board_games',
    EventCategory.clubbing => 'clubbing',
    EventCategory.wellness => 'wellness',
    EventCategory.movies => 'movies',
  };

  @override
  Future<void> cancelRsvp(String eventId) async {
    final String uid = _c.auth.currentUser!.id;
    await _c
        .from('rsvps')
        .update({'cancelled_at': DateTime.now().toIso8601String()})
        .eq('event_id', eventId)
        .eq('profile_id', uid)
        .isFilter('cancelled_at', null);
  }

  static Event _rowToEvent(
    Map<String, dynamic> row,
    Set<String> myRsvpEventIds,
  ) {
    final String id = row['id'] as String;
    final Map<String, dynamic>? cat =
        row['category'] as Map<String, dynamic>?;
    final String catCode = (cat?['code'] as String?) ?? 'art';
    final EventCategory category = _codeToCategory(catCode);

    final String policyCode =
        (row['gender_policy_code'] as String?) ?? 'everyone';
    final EventGenderPolicy policy = switch (policyCode) {
      'women_only' => EventGenderPolicy.womenOnly,
      'men_only' => EventGenderPolicy.menOnly,
      _ => EventGenderPolicy.everyone,
    };

    final List<String> avatarUrls = (row['attendee_avatar_urls'] as List?)
            ?.map((e) => e as String)
            .toList() ??
        <String>[];

    return Event(
      id: id,
      title: row['title'] as String,
      coverImageUrl: (row['cover_image_url'] as String?) ?? '',
      category: category,
      hostId: (row['host_id'] as String?) ?? 'system',
      hostName: (row['host_display_name'] as String?) ?? 'Lively',
      hostPhotoUrl: (row['host_display_photo_url'] as String?) ?? '',
      hostVerified: (row['host_display_verified'] as bool?) ?? true,
      hostBio: (row['host_display_bio'] as String?) ?? '',
      hostEventsHosted: (row['host_display_events_hosted'] as int?) ?? 0,
      hostRating: ((row['host_display_rating'] as num?) ?? 0).toDouble(),
      startTime: DateTime.parse(row['start_time'] as String).toLocal(),
      durationMinutes: row['duration_minutes'] as int,
      venueName: row['venue_name'] as String,
      venueAddress: row['venue_address'] as String,
      neighbourhood: (row['neighbourhood'] as String?) ?? '',
      priceRupees: row['price_rupees'] as int,
      // Per-gender pricing columns may not exist yet in every environment.
      // Read defensively — null falls back to the legacy price via helpers.
      priceRupeesWomen: row['price_rupees_women'] as int?,
      priceRupeesMen: row['price_rupees_men'] as int?,
      totalSpots: row['total_spots'] as int,
      maleRsvpCount: (row['male_rsvp_count'] as int?) ?? 0,
      femaleRsvpCount: (row['female_rsvp_count'] as int?) ?? 0,
      attendeeAvatarUrls: avatarUrls,
      description: (row['description'] as String?) ?? '',
      genderPolicy: policy,
      isGoing: myRsvpEventIds.contains(id),
    );
  }

  static EventCategory _codeToCategory(String code) => switch (code) {
    'art' => EventCategory.art,
    'sports' => EventCategory.sports,
    'food_and_drinks' => EventCategory.foodAndDrinks,
    'outdoors' => EventCategory.outdoors,
    'music' => EventCategory.music,
    'board_games' => EventCategory.boardGames,
    'clubbing' => EventCategory.clubbing,
    'wellness' => EventCategory.wellness,
    'movies' => EventCategory.movies,
    _ => EventCategory.art,
  };
}
