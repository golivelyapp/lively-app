import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/supabase_client.dart';

/// Reads/writes the current user's `profiles` row. Return values are
/// raw JSON maps for now — we type them in the Riverpod layer above.
class ProfileRepository {
  const ProfileRepository();

  SupabaseClient get _c => SupabaseService.client;

  Future<Map<String, dynamic>?> fetchMyProfile() async {
    final String? uid = _c.auth.currentUser?.id;
    if (uid == null) return null;
    return _c
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
  }

  Future<void> updateBasics({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String localityId,
    required String cityId,
  }) async {
    final String uid = _c.auth.currentUser!.id;
    await _c.from('profiles').update({
      'name': name,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'gender': gender,
      'locality_id': localityId,
      'city_id': cityId,
    }).eq('id', uid);
  }

  Future<void> setBio(String bio) async {
    final String uid = _c.auth.currentUser!.id;
    await _c.from('profiles').update({'bio': bio}).eq('id', uid);
  }

  Future<void> setActivities(List<String> activityIds) async {
    final String uid = _c.auth.currentUser!.id;
    await _c.from('profiles').update({'activities': activityIds}).eq('id', uid);
  }

  Future<void> submitForReview() async {
    final String uid = _c.auth.currentUser!.id;
    await _c
        .from('profiles')
        .update({'review_status': 'submitted'})
        .eq('id', uid);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return const ProfileRepository();
});
