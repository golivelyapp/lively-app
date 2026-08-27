import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/api/env.dart';
import 'core/api/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.hasSupabaseConfig) {
    // Fail loud during development — silently running against no backend
    // is worse than a crash.
    throw StateError(
      'Missing SUPABASE_URL / SUPABASE_ANON_KEY. Pass them via '
      '--dart-define-from-file=.env.json when running or building.',
    );
  }

  await SupabaseService.initialize();
  runApp(const ProviderScope(child: LivelyApp()));
}
