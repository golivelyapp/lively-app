import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../models/host_verification_status.dart';

/// Derived from `profiles.host_status` in Supabase — survives app kill.
/// Maps the DB enum ('none'|'applied'|'under_review'|'approved'|'rejected'|
/// 'suspended') to the UI enum. Falls back to `unverified` while the
/// profile is still loading or if the column is missing.
final hostVerificationStatusProvider = Provider<HostVerificationStatus>((ref) {
  final profileAsync = ref.watch(currentProfileProvider);
  return profileAsync.when(
    loading: () => HostVerificationStatus.unverified,
    error: (_, __) => HostVerificationStatus.unverified,
    data: (profile) {
      final String code = profile?['host_status'] as String? ?? 'none';
      return switch (code) {
        'approved' => HostVerificationStatus.approved,
        'under_review' => HostVerificationStatus.underReview,
        'applied' => HostVerificationStatus.idSubmitted,
        'rejected' || 'suspended' => HostVerificationStatus.rejected,
        _ => HostVerificationStatus.unverified,
      };
    },
  );
});

final isVerifiedHostProvider = Provider<bool>((ref) {
  return ref.watch(hostVerificationStatusProvider) == HostVerificationStatus.approved;
});
