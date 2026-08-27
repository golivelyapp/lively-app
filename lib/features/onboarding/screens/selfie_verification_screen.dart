import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/onboarding_step.dart';
import '../widgets/onboarding_scaffold.dart';

class SelfieVerificationScreen extends StatefulWidget {
  const SelfieVerificationScreen({
    required this.profilePhotoPath,
    required this.onContinue,
    super.key,
  });

  final String profilePhotoPath;
  final ValueChanged<String> onContinue;

  @override
  State<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends State<SelfieVerificationScreen> {
  bool _capturing = false;

  Future<void> _takeSelfie() async {
    setState(() => _capturing = true);
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    if (!mounted) return;
    setState(() => _capturing = false);
    if (file != null) widget.onContinue(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progressRatio: OnboardingStep.selfieVerification.progressRatio,
      bottomAction: ElevatedButton(
        onPressed: _capturing ? null : _takeSelfie,
        child: Text(_capturing ? 'Opening camera…' : 'Take selfie'),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 24),
          Text('Selfie Verification', textAlign: TextAlign.center, style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.xl),
          CircleAvatar(
            radius: 90,
            backgroundImage: FileImage(File(widget.profilePhotoPath)),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Is this really you?', style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Everyone on Lively is selfie-verified. Just take a quick '
            "selfie once - it's only used to confirm you are you.",
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
