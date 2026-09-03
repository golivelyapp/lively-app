import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/providers/profile_hydration.dart';

class LivelyApp extends ConsumerWidget {
  const LivelyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    // Wire the profile hydration listener for the whole session — the
    // moment currentProfileProvider resolves it mirrors the row into
    // onboardingDraftProvider so the UI has the user's data even after
    // a cold start.
    ref.watch(profileHydrationProvider);

    return MaterialApp.router(
      title: 'Lively',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
