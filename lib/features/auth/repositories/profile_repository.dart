import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/supabase_client.dart';

/// Reads/writes the current user's `profiles` row + related tables.
/// Every method assumes there IS a session — callers must check.
class ProfileRepository {
  const ProfileRepository();

  SupabaseClient get _c => SupabaseService.client;
  String get _uid => _c.auth.currentUser!.id;

  Future<Map<String, dynamic>?> fetchMyProfile() async {
    if (_c.auth.currentSession == null) return null;
    return _c
        .from('profiles')
        .select()
        .eq('id', _uid)
        .maybeSingle();
  }

  /// The single Bangalore city row seeded in the migration.
  Future<String> defaultCityId() async {
    final row = await _c
        .from('cities')
        .select('id')
        .eq('code', 'bengaluru')
        .single();
    return row['id'] as String;
  }

  Future<List<Map<String, dynamic>>> fetchLocalities() async {
    return List<Map<String, dynamic>>.from(
      await _c
          .from('localities')
          .select('id, name, slug, display_order')
          .eq('is_active', true)
          .order('display_order'),
    );
  }

  Future<List<Map<String, dynamic>>> fetchActivityCategories() async {
    return List<Map<String, dynamic>>.from(
      await _c
          .from('activity_categories')
          .select('id, code, label, icon_name, display_order')
          .eq('is_active', true)
          .order('display_order'),
    );
  }

  Future<void> updateBasics({
    required String name,
    required DateTime dateOfBirth,
    required String gender,        // 'male' | 'female' | 'other'
    required String cityId,
    required String localityId,
  }) async {
    await _c.from('profiles').update({
      'name': name,
      'date_of_birth':
          '${dateOfBirth.year.toString().padLeft(4, '0')}-'
          '${dateOfBirth.month.toString().padLeft(2, '0')}-'
          '${dateOfBirth.day.toString().padLeft(2, '0')}',
      'gender': gender,
      'city_id': cityId,
      'locality_id': localityId,
    }).eq('id', _uid);
  }

  Future<void> setBio(String bio) async {
    await _c.from('profiles').update({'bio': bio}).eq('id', _uid);
  }

  Future<void> setActivities(List<String> activityIds) async {
    await _c
        .from('profiles')
        .update({'activities': activityIds})
        .eq('id', _uid);
  }

  /// Uploads a photo to Storage and inserts a matching `attachments` row.
  /// Returns the public URL (for public buckets) or signed URL (private).
  Future<String> uploadPhoto({
    required File file,
    required String bucket,        // 'avatars' | 'verifications' | ...
    required String purpose,       // 'avatar' | 'selfie' | 'id_scan' | ...
    required String ownerType,     // 'profile' | 'host_application' | ...
    required String ownerId,
  }) async {
    // Path convention: <owner_id>/<epoch>_<purpose>.<ext>
    final String ext = file.path.split('.').last.toLowerCase();
    final String path =
        '$ownerId/${DateTime.now().millisecondsSinceEpoch}_$purpose.$ext';
    await _c.storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(
            contentType: 'image/$ext',
            upsert: false,
          ),
        );
    final String url = _c.storage.from(bucket).getPublicUrl(path);
    // Track in the unified attachments table so cleanup + moderation
    // work later.
    await _c.from('attachments').insert({
      'owner_type': ownerType,
      'owner_id': ownerId,
      'purpose': purpose,
      'storage_bucket': bucket,
      'storage_path': path,
      'mime_type': 'image/$ext',
      'is_public': bucket == 'avatars' || bucket == 'event_covers' || bucket == 'event_gallery',
    });
    return url;
  }

  Future<void> submitForReview() async {
    await _c
        .from('profiles')
        .update({'review_status': 'submitted'})
        .eq('id', _uid);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return const ProfileRepository();
});
