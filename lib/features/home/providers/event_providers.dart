import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../onboarding/models/onboarding_enums.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';
import '../models/event.dart';
import '../models/event_category.dart';
import '../repositories/event_repository.dart';
import '../repositories/supabase_event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return const SupabaseEventRepository();
});

class EventsController extends Notifier<List<Event>> {
  @override
  List<Event> build() {
    // Auto-refetch on any auth state change (sign-in flips isGoing).
    ref.watch(authStateChangesProvider);
    _refresh();
    return <Event>[];
  }

  Future<void> refresh() => _refresh();

  Future<void> _refresh() async {
    try {
      final events = await ref.read(eventRepositoryProvider).fetchEvents();
      state = events;
    } catch (e) {
      // Keep prior state on transient errors so a Wi-Fi blip doesn't
      // wipe the feed.
      // ignore: avoid_print
      print('EventsController._refresh failed: $e');
    }
  }

  /// Optimistically flip isGoing + spot counts, then persist to Supabase.
  /// If the write fails, revert.
  Future<void> toggleRsvp(String eventId) async {
    final int idx = state.indexWhere((e) => e.id == eventId);
    if (idx == -1) return;
    final Event current = state[idx];
    final bool willJoin = !current.isGoing;

    final Gender myGender =
        ref.read(onboardingDraftProvider).gender ?? Gender.female;
    final int delta = willJoin ? 1 : -1;

    final Event optimistic = current.copyWith(
      isGoing: willJoin,
      maleRsvpCount:
          current.maleRsvpCount + (myGender == Gender.male ? delta : 0),
      femaleRsvpCount:
          current.femaleRsvpCount + (myGender != Gender.male ? delta : 0),
    );
    state = <Event>[
      for (int i = 0; i < state.length; i++)
        if (i == idx) optimistic else state[i],
    ];

    try {
      final repo = ref.read(eventRepositoryProvider);
      if (willJoin) {
        await repo.rsvp(eventId);
      } else {
        await repo.cancelRsvp(eventId);
      }
      // Server counters may have moved (other users RSVP'd concurrently);
      // pull a fresh copy so numbers match reality.
      _refresh();
    } catch (e) {
      // Revert on failure.
      state = <Event>[
        for (int i = 0; i < state.length; i++)
          if (i == idx) current else state[i],
      ];
      rethrow;
    }

    // Channel + channel_members are kept in sync by DB triggers (0009),
    // so no client-side chat bookkeeping is needed here anymore.
  }

  /// Called by Create Event flow — kept for future compatibility. The
  /// real path writes to Supabase; this pushes the fresh event into
  /// local state so it appears in the feed without a refetch.
  void publish(Event event) {
    state = <Event>[event, ...state];
  }
}

final eventsProvider = NotifierProvider<EventsController, List<Event>>(
  EventsController.new,
);

/// Home feed filter. Always defaults to 'all' so a fresh login lands on
/// the unfiltered feed. The pill ORDER still puts the user's onboarding
/// interests first (see [homeCategoryPillsProvider]) — only the default
/// selection is 'all'.
final homeFilterProvider = StateProvider<String>((ref) => 'all');

/// Sticky women-only sub-filter (only offered to female users).
final womenOnlyFilterProvider = StateProvider<bool>((ref) => false);

/// Date bucket for the second filter row on Home. 'anytime' means the
/// row is inactive and doesn't constrain the feed.
enum DateFilter { anytime, today, tomorrow, weekend, later }

extension DateFilterLabel on DateFilter {
  String get label => switch (this) {
    DateFilter.anytime => 'Any time',
    DateFilter.today => 'Today',
    DateFilter.tomorrow => 'Tomorrow',
    DateFilter.weekend => 'This weekend',
    DateFilter.later => 'Later',
  };
}

final dateFilterProvider =
    StateProvider<DateFilter>((ref) => DateFilter.anytime);

/// Seeded from the onboarding Basics location — the Home location pill
/// reflects whatever the user chose (or GPS auto-detected) during signup.
final locationLabelProvider = StateProvider<String>((ref) {
  return ref.watch(onboardingDraftProvider).location ?? 'Koramangala';
});

final imFreeProvider = StateProvider<bool>((ref) => false);

/// Category pills to render on Home: All + the user's onboarding interests
/// mapped to event categories (deduped, order preserved). Falls back to the
/// full category list when the user hasn't selected any interests yet.
final homeCategoryPillsProvider = Provider<List<EventCategory>>((ref) {
  final Set<String> activities = ref.watch(
    onboardingDraftProvider.select((d) => d.activities),
  );
  if (activities.isEmpty) return EventCategory.values;
  final List<EventCategory> ordered = <EventCategory>[];
  for (final String label in activities) {
    final EventCategory? c = EventCategoryDisplay.fromActivityLabel(label);
    if (c != null && !ordered.contains(c)) ordered.add(c);
  }
  for (final EventCategory c in EventCategory.values) {
    if (!ordered.contains(c)) ordered.add(c);
  }
  return ordered;
});

final filteredEventsProvider = Provider<List<Event>>((ref) {
  final List<Event> events = ref.watch(eventsProvider);
  final String filter = ref.watch(homeFilterProvider);
  final bool womenOnly = ref.watch(womenOnlyFilterProvider);
  final DateFilter dateFilter = ref.watch(dateFilterProvider);
  final Gender? myGender = ref.watch(
    onboardingDraftProvider.select((d) => d.gender),
  );

  Iterable<Event> upcoming = events.where((e) => !e.isPast);

  // Gender-based visibility.
  if (myGender != Gender.female) {
    upcoming = upcoming.where((e) => !e.isWomenOnly);
  }
  if (myGender == Gender.female) {
    upcoming = upcoming.where((e) => !e.isMenOnly);
  }

  if (filter != 'all') {
    final EventCategory category = EventCategory.values.byName(filter);
    upcoming = upcoming.where((e) => e.category == category);
  }
  if (womenOnly) {
    upcoming = upcoming.where((e) => e.isWomenOnly);
  }

  final DateTime now = DateTime.now();
  final DateTime todayStart = DateTime(now.year, now.month, now.day);
  final DateTime tomorrowStart = todayStart.add(const Duration(days: 1));
  final DateTime dayAfterTomorrow = todayStart.add(const Duration(days: 2));
  final int daysToSat = (DateTime.saturday - now.weekday + 7) % 7;
  final DateTime satStart = todayStart.add(Duration(days: daysToSat));
  final DateTime mondayAfter = satStart.add(const Duration(days: 2));
  final DateTime endOfNextWeek = todayStart.add(const Duration(days: 14));

  switch (dateFilter) {
    case DateFilter.anytime:
      break;
    case DateFilter.today:
      upcoming = upcoming.where((e) =>
          e.startTime.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
          e.startTime.isBefore(tomorrowStart));
      break;
    case DateFilter.tomorrow:
      upcoming = upcoming.where((e) =>
          e.startTime.isAfter(tomorrowStart.subtract(const Duration(seconds: 1))) &&
          e.startTime.isBefore(dayAfterTomorrow));
      break;
    case DateFilter.weekend:
      upcoming = upcoming.where((e) =>
          e.startTime.isAfter(satStart.subtract(const Duration(seconds: 1))) &&
          e.startTime.isBefore(mondayAfter));
      break;
    case DateFilter.later:
      upcoming = upcoming.where((e) => e.startTime.isAfter(endOfNextWeek));
      break;
  }

  final List<Event> list = upcoming.toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  return list;
});

final upcomingRsvpsProvider = Provider<List<Event>>((ref) {
  final List<Event> events = ref.watch(eventsProvider);
  final List<Event> rsvpd = events
      .where((e) => e.isGoing && !e.isPast)
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  return rsvpd;
});

final showWomenOnlyFilterProvider = Provider<bool>((ref) {
  final Gender? gender = ref.watch(
    onboardingDraftProvider.select((d) => d.gender),
  );
  return gender == Gender.female;
});

final eventByIdProvider = Provider.family<Event?, String>((ref, id) {
  for (final Event e in ref.watch(eventsProvider)) {
    if (e.id == id) return e;
  }
  return null;
});
