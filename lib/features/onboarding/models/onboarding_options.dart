import 'package:flutter/material.dart';
import 'chip_option.dart';

/// Activity categories shown on the onboarding "Activities of Interest"
/// screen AND on the Home filter pills AND on the Create Event category
/// picker. Must stay in sync with the `activity_categories` seed data in
/// supabase/migrations/0001_init.sql.
const List<ChipOption> activityOptions = <ChipOption>[
  ChipOption('Art',           icon: Icons.palette_outlined),
  ChipOption('Sports',        icon: Icons.sports_basketball_outlined),
  ChipOption('Food & Drinks', icon: Icons.restaurant_outlined),
  ChipOption('Outdoors',      icon: Icons.terrain_outlined),
  ChipOption('Music',         icon: Icons.graphic_eq_outlined),
  ChipOption('Board Games',   icon: Icons.casino_outlined),
  ChipOption('Clubbing',      icon: Icons.nightlife_outlined),
  ChipOption('Wellness',      icon: Icons.self_improvement_outlined),
  ChipOption('Movies',        icon: Icons.movie_outlined),
];

const int maxActivitySelection = 3;

/// Personality traits — optional profile enhancement (Profile tab).
/// Not backed by DB rows; stored as text[] on the profile so this list
/// can grow freely without a migration.
const List<ChipOption> traitOptions = <ChipOption>[
  ChipOption('Analytical'),
  ChipOption('Supportive'),
  ChipOption('Proactive'),
  ChipOption('Sociable'),
  ChipOption('Responsible'),
  ChipOption('Tolerant'),
  ChipOption('Punctual'),
  ChipOption('Empathetic'),
  ChipOption('Independent'),
  ChipOption('Leader'),
  ChipOption('Curious'),
  ChipOption('Motivated'),
  ChipOption('Wise'),
  ChipOption('Adaptable'),
  ChipOption('Ambitious'),
  ChipOption('Committed'),
  ChipOption('Assertive'),
  ChipOption('Practical'),
  ChipOption('Creative'),
  ChipOption('Optimistic'),
  ChipOption('Emotional'),
  ChipOption('Confident'),
  ChipOption('Passionate'),
  ChipOption('Loyal'),
  ChipOption('Reliable'),
  ChipOption('Humble'),
  ChipOption('Introvert'),
  ChipOption('Extrovert'),
  ChipOption('Chill'),
  ChipOption('Deep Thinker'),
  ChipOption('Playful'),
  ChipOption('Sarcastic'),
  ChipOption('Grounded'),
  ChipOption('Bold'),
  ChipOption('Kind'),
  ChipOption('Curious mind'),
];

const int maxTraitSelection = 3;
