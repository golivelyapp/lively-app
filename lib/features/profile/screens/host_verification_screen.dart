import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../auth/repositories/profile_repository.dart';
import '../models/host_verification_status.dart';
import '../providers/host_verification_provider.dart';

/// Real ID verification and AI selfie-matching need a backend this app
/// doesn't have yet — this models the exact user-facing steps, with the
/// review step auto-approving after a short delay as the stand-in.
class HostVerificationScreen extends ConsumerStatefulWidget {
  const HostVerificationScreen({super.key});

  @override
  ConsumerState<HostVerificationScreen> createState() => _HostVerificationScreenState();
}

class _HostVerificationScreenState extends ConsumerState<HostVerificationScreen> {
  String? _idPhotoPath;

  Future<void> _pickId() async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) setState(() => _idPhotoPath = file.path);
  }

  Future<void> _takeSelfie() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    if (file == null) return;

    final ProfileRepository repo = ref.read(profileRepositoryProvider);

    // Persist the transition to Supabase so it survives an app kill.
    try {
      await repo.setHostStatus('under_review');
      ref.read(profileRefreshTriggerProvider.notifier).state++;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit verification: $e')),
      );
      return;
    }

    Future.delayed(const Duration(seconds: 4), () async {
      if (!mounted) return;
      try {
        await repo.setHostStatus('approved');
        ref.read(profileRefreshTriggerProvider.notifier).state++;
      } catch (_) {
        // If the approval write fails the user stays in review; router
        // will pick up the real state on next fetch. Silent is fine — the
        // pending screen already communicates the state.
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(hostVerificationStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: status == HostVerificationStatus.underReview
              ? _PendingReview()
              : _idPhotoPath == null
              ? _IdUploadStep(onPick: _pickId)
              : _SelfieStep(idPhotoPath: _idPhotoPath!, onTakeSelfie: _takeSelfie),
        ),
      ),
    );
  }
}

class _IdUploadStep extends StatelessWidget {
  const _IdUploadStep({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Verify your identity', style: AppTextStyles.displayLg),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          "Hosts are verified so attendees know they're safe. Upload a "
          "government ID (Aadhaar, PAN, or driving licence) — it's "
          'encrypted and never shared.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppSpacing.xl),
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: const Icon(Icons.badge_outlined, size: 40, color: AppColors.textSecondary),
          ),
        ),
        const Spacer(),
        GradientButton(label: 'Upload ID', onPressed: onPick),
      ],
    );
  }
}

class _SelfieStep extends StatelessWidget {
  const _SelfieStep({required this.idPhotoPath, required this.onTakeSelfie});

  final String idPhotoPath;
  final VoidCallback onTakeSelfie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Match your selfie', style: AppTextStyles.displayLg),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Take a live selfie so we can match it against your ID photo — '
          'this stops anyone else using your ID.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppSpacing.xl),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Image.file(File(idPhotoPath), height: 160, width: double.infinity, fit: BoxFit.cover),
        ),
        const Spacer(),
        GradientButton(label: 'Take selfie', onPressed: onTakeSelfie),
      ],
    );
  }
}

class _PendingReview extends StatelessWidget {
  const _PendingReview();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const CircularProgressIndicator(color: AppColors.magenta),
        const SizedBox(height: AppSpacing.lg),
        Text('Verifying your identity', style: AppTextStyles.headline, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'This usually takes under 24 hours. We\'ll notify you once approved.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}
