import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chats/providers/event_chat_provider.dart';
import '../../onboarding/models/onboarding_enums.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';
import '../models/event.dart';
import '../models/event_category.dart';
import '../repositories/event_repository.dart';
import '../repositories/mock_event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return MockEventRepository();
});

class EventsController extends Notifier<List<Event>> {
  @override
  List<Event> build() => ref.read(eventRepositoryProvider).fetchEvents();

  void toggleRsvp(String eventId) {
    final Event current = state.firstWhere(
      (e) => e.id == eventId,
      orElse: () => throw StateError('Event $eventId not found'),
    );
    final bool willJoin = !current.isGoing;

    // Which gender bucket to bump depends on the current user. Gender is
    // stored in the onboarding draft — fall back to "female" for the
    // preview build so the count still moves.
    final Gender myGender =
        ref.read(onboardingDraftProvider).gender ?? Gender.female;
    final int delta = willJoin ? 1 : -1;
    state = <Event>[
      for (final Event e in state)
        if (e.id == eventId)
          e.copyWith(
            isGoing: willJoin,
            maleRsvpCount:
                e.maleRsvpCount + (myGender == Gender.male ? delta : 0),
            femaleRsvpCount:
                e.femaleRsvpCount + (myGender != Gender.male ? delta : 0),
          )
        else
          e,
    ];

    final String userName =
        ref.read(onboardingDraftProvider).name ?? 'Someone';
    if (willJoin) {
      ref.read(eventChatsProvider.notifier).joinChat(
            event: state.firstWhere((e) => e.id == eventId),
            userName: userName,
          );
    } else {
      ref.read(eventChatsProvider.notifier).leaveChat(
            eventId: eventId,
            userName: userName,
          );
    }
  }

  void publish(Event event) {
    state = <Event>[event, ...state];
  }
}

final eventsProvider = NotifierProvider<EventsController, List<Event>>(
  EventsController.new,
);

/// Home feed filter. Defaults to the user's FIRST onboarding interest
/// (if one exists and maps to a real category) so returning to Home
/// feels immediately personalised. Falls back to 'all' otherwise.
final homeFilterProvider = StateProvider<String>((ref) {
  final Set<String> activities = ref.read(
    onboardingDraftProvider.select((d) => d.activities),
  );
  for (final String label in activities) {
    final EventCategory? c = EventCategoryDisplay.fromActivityLabel(label);
    if (c != null) return c.name;
  }
  return 'all';
});

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

final dateFilterProvider = StateProvider<DateFilter>((ref) => DateFilter.anytime);

/// Seeded from the onboarding Basics location — the Home location pill
/// reflects whatever the user chose (or GPS auto-detected) during signup.
final locationLabelProvider = StateProvider<String>((ref) {
  return ref.read(onboardingDraftProvider).location ?? 'Koramangala';
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

  // You don't browse your own events — you manage them from the
   // Profile tab. Host-created events are keyed by the sentinel 'me'.
   Iterable<Event> upcoming = events.where((e) => !e.isPast && e.hostId != 'me');

  // Gender-based visibility: male/other users never see women-only
  // events. Female users see everything (they can also opt in to the
  // women-only sub-filter for a subset).
  if (myGender != Gender.female) {
    upcoming = upcoming.where((e) => !e.isWomenOnly);
  }
  // Similarly, hide men-only events from female users if a host ever
  // creates one (we don't seed any today, but the switch is here).
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

  // Date bucket filter — computed against 'now' at read time so the
  // buckets stay accurate as the day progresses.
  final DateTime now = DateTime.now();
  final DateTime todayStart = DateTime(now.year, now.month, now.day);
  final DateTime tomorrowStart = todayStart.add(const Duration(days: 1));
  final DateTime dayAfterTomorrow = todayStart.add(const Duration(days: 2));
  // "This weekend" = upcoming Saturday 00:00 through Sunday 23:59.
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

/// The user's RSVP'd upcoming events, sorted by soonest.
final upcomingRsvpsProvider = Provider<List<Event>>((ref) {
  final List<Event> events = ref.watch(eventsProvider);
  final List<Event> rsvpd = events
      .where((e) => e.isGoing && !e.isPast)
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  return rsvpd;
});

/// Only show the "Women only" chip when the user is female.
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
