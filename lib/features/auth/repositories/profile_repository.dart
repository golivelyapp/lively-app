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
  /// Returns the public URL. Throws with actionable messages on failure so
  /// the caller can surface them.
  Future<String> uploadPhoto({
    required File file,
    required String bucket,        // 'avatars' | 'verifications' | ...
    required String purpose,       // 'avatar' | 'selfie' | 'id_scan' | ...
    required String ownerType,     // 'profile' | 'host_application' | ...
    required String ownerId,
  }) async {
    if (!await file.exists()) {
      throw StateError('Photo file no longer exists on device.');
    }
    // Path convention: <owner_id>/<epoch>_<purpose>.<ext>
    // The (owner_id, purpose) prefix is the RLS boundary — storage policies
    // check that (storage.foldername(name))[1] == auth.uid().
    final String extRaw = file.path.split('.').last.toLowerCase();
    final String ext = _normaliseExt(extRaw);
    final String mimeType = _mimeFor(ext);
    final String path =
        '$ownerId/${DateTime.now().millisecondsSinceEpoch}_$purpose.$ext';

    try {
      await _c.storage.from(bucket).upload(
            path,
            file,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: false,
            ),
          );
    } on StorageException catch (e) {
      throw Exception('Storage upload failed: ${e.message}');
    }

    final String url = _c.storage.from(bucket).getPublicUrl(path);

    try {
      await _c.from('attachments').insert({
        'owner_type': ownerType,
        'owner_id': ownerId,
        'purpose': purpose,
        'storage_bucket': bucket,
        'storage_path': path,
        'mime_type': mimeType,
        'bytes': await file.length(),
        'is_public': bucket == 'avatars' ||
            bucket == 'event_covers' ||
            bucket == 'event_gallery',
      });
    } on PostgrestException catch (e) {
      // If the DB insert fails, clean up the orphaned storage object so
      // retries don't hit "already exists" on the next attempt.
      try {
        await _c.storage.from(bucket).remove(<String>[path]);
      } catch (_) {}
      throw Exception('Attachment record failed: ${e.message}');
    }

    // Denormalise the avatar URL onto profiles.avatar_url so every display
    // site (You tab, event card host row, event detail host card, chat
    // list preview) can render it without joining the attachments table.
    // Without this, the URL was previously discarded after upload.
    if (purpose == 'avatar' &&
        ownerType == 'profile' &&
        ownerId == _uid) {
      try {
        await _c
            .from('profiles')
            .update(<String, Object?>{'avatar_url': url})
            .eq('id', _uid);
      } on PostgrestException catch (_) {
        // Non-fatal: attachment already exists, URL just isn't on the
        // profile row. Don't roll back the whole upload for this.
      }
    }

    return url;
  }

  static String _normaliseExt(String ext) => switch (ext) {
    'jpeg' => 'jpg',
    'heic' || 'heif' => 'jpg',   // ImagePicker converts iOS HEIC to JPG
    _ => ext,
  };

  static String _mimeFor(String ext) => switch (ext) {
    'jpg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/$ext',
  };

  Future<void> submitForReview() async {
    await _c
        .from('profiles')
        .update({'review_status': 'submitted'})
        .eq('id', _uid);
  }

  /// Persists a host verification transition to `profiles.host_status`.
  /// [status] must be one of the DB enum values: 'none' | 'applied' |
  /// 'under_review' | 'approved' | 'rejected' | 'suspended'.
  Future<void> setHostStatus(String status) async {
    await _c
        .from('profiles')
        .update({'host_status': status})
        .eq('id', _uid);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return const ProfileRepository();
});
