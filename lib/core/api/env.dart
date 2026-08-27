class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// True once a real Supabase project is wired in via
  /// `--dart-define-from-file=.env.json`. Until then, sign-in and the
  /// onboarding submit step are stubbed locally instead of hitting a
  /// backend that doesn't exist yet.
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static const bool skipOnboarding = bool.fromEnvironment('SKIP_ONBOARDING');
  static const bool previewMode = bool.fromEnvironment('PREVIEW_MODE');
}
