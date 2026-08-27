import 'package:flutter/material.dart';

enum EventCategory {
  art,
  sports,
  foodAndDrinks,
  outdoors,
  music,
  boardGames,
  clubbing,
  wellness,
  movies,
}

extension EventCategoryDisplay on EventCategory {
  String get label => switch (this) {
    EventCategory.art => 'Art',
    EventCategory.sports => 'Sports',
    EventCategory.foodAndDrinks => 'Food & Drinks',
    EventCategory.outdoors => 'Outdoors',
    EventCategory.music => 'Music',
    EventCategory.boardGames => 'Board Games',
    EventCategory.clubbing => 'Clubbing',
    EventCategory.wellness => 'Wellness',
    EventCategory.movies => 'Movies',
  };

  IconData get icon => switch (this) {
    EventCategory.art => Icons.palette_outlined,
    EventCategory.sports => Icons.sports_basketball_outlined,
    EventCategory.foodAndDrinks => Icons.restaurant_outlined,
    EventCategory.outdoors => Icons.terrain_outlined,
    EventCategory.music => Icons.graphic_eq_outlined,
    EventCategory.boardGames => Icons.casino_outlined,
    EventCategory.clubbing => Icons.nightlife_outlined,
    EventCategory.wellness => Icons.self_improvement_outlined,
    EventCategory.movies => Icons.movie_outlined,
  };

  static EventCategory? fromActivityLabel(String label) {
    final String lower = label.toLowerCase();
    if (lower.contains('art') || lower.contains('paint') || lower.contains('read') || lower.contains('book') || lower.contains('craft')) {
      return EventCategory.art;
    }
    if (lower.contains('sport') || lower.contains('gym') || lower.contains('run') || lower.contains('cricket') || lower.contains('football') || lower.contains('badminton') || lower.contains('cycling') || lower.contains('climb')) {
      return EventCategory.sports;
    }
    if (lower.contains('food') || lower.contains('cook') || lower.contains('coffee') || lower.contains('dine') || lower.contains('brunch') || lower.contains('chai')) {
      return EventCategory.foodAndDrinks;
    }
    if (lower.contains('hike') || lower.contains('trek') || lower.contains('outdoor') || lower.contains('camp') || lower.contains('walk')) {
      return EventCategory.outdoors;
    }
    if (lower.contains('music') || lower.contains('concert') || lower.contains('sing') || lower.contains('band') || lower.contains('gig')) {
      return EventCategory.music;
    }
    if (lower.contains('board') || lower.contains('game') || lower.contains('trivia') || lower.contains('quiz')) {
      return EventCategory.boardGames;
    }
    if (lower.contains('club') || lower.contains('party') || lower.contains('dance')) {
      return EventCategory.clubbing;
    }
    if (lower.contains('yoga') || lower.contains('medit') || lower.contains('wellness') || lower.contains('spa')) {
      return EventCategory.wellness;
    }
    if (lower.contains('movie') || lower.contains('film') || lower.contains('cinema')) {
      return EventCategory.movies;
    }
    return null;
  }
}
