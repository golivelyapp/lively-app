class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Deep-link scheme registered with Supabase for OAuth redirects.
  /// The Android intent filter (below) picks up lively://login-callback/
  /// and returns the user into the app.
  static const String authRedirectUrl = 'lively://login-callback/';

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static const bool skipOnboarding = bool.fromEnvironment('SKIP_ONBOARDING');
  static const bool previewMode = bool.fromEnvironment('PREVIEW_MODE');
}
