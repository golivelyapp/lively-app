import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/supabase_client.dart';
import '../models/onboarding_draft.dart';
import '../models/onboarding_enums.dart';
import 'onboarding_repository.dart';

class SupabaseOnboardingRepository implements OnboardingRepository {
  const SupabaseOnboardingRepository();

  SupabaseClient get _client => SupabaseService.client;
  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<String> uploadPhoto(File file, {required String purpose}) async {
    final String ext = file.path.split('.').last;
    final String path = '$_userId/$purpose-${DateTime.now().microsecondsSinceEpoch}.$ext';
    await _client.storage.from('profile-photos').upload(path, file);
    return _client.storage.from('profile-photos').getPublicUrl(path);
  }

  @override
  Future<void> submitForReview(OnboardingDraft draft) async {
    await _client.from('profiles').upsert(<String, dynamic>{
      'id': _userId,
      'name': draft.name,
      'date_of_birth': draft.dateOfBirth?.toIso8601String(),
      'company': draft.company,
      'profession': draft.profession,
      'location': draft.location,
      'gender': draft.gender?.name,
      'status': draft.status?.name,
      'profile_photo_path': draft.profilePhotoPath,
      'height_cm': draft.heightCm,
      'activities': draft.activities.toList(),
      'traits': draft.traits.toList(),
      'musicians': draft.musicians.map((p) => p.toJson()).toList(),
      'movies': draft.movies.map((p) => p.toJson()).toList(),
      'dishes': draft.dishes.map((p) => p.toJson()).toList(),
      'bio': draft.bio,
      'socials': draft.socials.map((s) => s.toJson()).toList(),
      'selfie_photo_path': draft.selfiePhotoPath,
      'review_status': ProfileReviewStatus.submitted.name,
    });
    await _client.auth.updateUser(
      UserAttributes(data: <String, dynamic>{'onboarded': true}),
    );
  }
}
