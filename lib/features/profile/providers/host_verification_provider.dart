import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/host_verification_status.dart';

final hostVerificationStatusProvider =
    StateProvider<HostVerificationStatus>((ref) => HostVerificationStatus.unverified);

final isVerifiedHostProvider = Provider<bool>((ref) {
  return ref.watch(hostVerificationStatusProvider) == HostVerificationStatus.approved;
});
