import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/supabase_client.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../models/onboarding_draft.dart';
import '../models/onboarding_enums.dart';
import 'onboarding_draft_controller.dart';

/// Watches `currentProfileProvider` and mirrors it into the local
/// `onboardingDraftProvider` on every successful fetch. This is what
/// makes the app's client state survive a cold restart: after auth
/// hydrates the session, we pull the profile row from Supabase, then
/// project it into the shape the UI already reads.
///
/// Call `ref.watch(profileHydrationProvider)` from a widget that stays
/// mounted for the whole session (e.g. `app.dart`'s root) so the
/// listener wires up once.
final profileHydrationProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<Map<String, dynamic>?>>(
    currentProfileProvider,
    (previous, next) async {
      final Map<String, dynamic>? profile = next.value;
      if (profile == null) return;
      await _hydrate(ref, profile);
    },
    fireImmediately: true,
  );
});

Future<void> _hydrate(Ref ref, Map<String, dynamic> profile) async {
  final draft = ref.read(onboardingDraftProvider);
  final controller = ref.read(onboardingDraftProvider.notifier);

  // --- Basics ------------------------------------------------------------
  final String? name = profile['name'] as String?;
  final String? dobStr = profile['date_of_birth'] as String?;
  final DateTime? dob = dobStr == null ? null : DateTime.tryParse(dobStr);
  final String? genderCode = profile['gender'] as String?;
  final Gender? gender = switch (genderCode) {
    'male' => Gender.male,
    'female' => Gender.female,
    'other' => Gender.other,
    _ => null,
  };

  // Locality is stored as a UUID on profiles; the app UI works with the
  // name string. Resolve it.
  String? localityName;
  final String? localityId = profile['locality_id'] as String?;
  if (localityId != null) {
    try {
      final row = await SupabaseService.client
          .from('localities')
          .select('name')
          .eq('id', localityId)
          .maybeSingle();
      localityName = row?['name'] as String?;
    } catch (_) {}
  }

  controller.updateBasics(
    name: name ?? draft.name,
    dateOfBirth: dob ?? draft.dateOfBirth,
    location: localityName ?? draft.location,
    gender: gender ?? draft.gender,
  );

  // --- Bio ---------------------------------------------------------------
  final String? bio = profile['bio'] as String?;
  if (bio != null && bio.isNotEmpty && bio != draft.bio) {
    controller.updateBio(bio);
  }

  // --- Activities --------------------------------------------------------
  // Stored as uuid[] on profiles; the client uses label strings.
  final List<dynamic>? activityIds = profile['activities'] as List?;
  if (activityIds != null && activityIds.isNotEmpty) {
    try {
      final rows = await SupabaseService.client
          .from('activity_categories')
          .select('id, label')
          .inFilter('id', activityIds.map((e) => e as String).toList());
      final labels = <String>{
        for (final row in rows) row['label'] as String,
      };
      controller.setActivities(labels);
    } catch (_) {}
  }

  // --- Photo -------------------------------------------------------------
  // Mirror the persisted avatar URL from profiles.avatar_url into
  // draft.profilePhotoPath. `photoImageProvider` already switches
  // between NetworkImage / FileImage on `startsWith('http')`, so this
  // just works for every display site (You tab, etc.).
  final String? avatarUrl = profile['avatar_url'] as String?;
  if (avatarUrl != null && avatarUrl.isNotEmpty &&
      avatarUrl != draft.profilePhotoPath) {
    controller.setProfilePhoto(avatarUrl);
  }
}

/// Prefer this convenience: read a Supabase-hydrated OnboardingDraft
/// anywhere in the app. Ensures the hydration listener is active.
OnboardingDraft useHydratedDraft(WidgetRef ref) {
  ref.watch(profileHydrationProvider);
  return ref.watch(onboardingDraftProvider);
}
