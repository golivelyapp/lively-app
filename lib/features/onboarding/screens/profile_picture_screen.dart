import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../models/onboarding_step.dart';
import '../widgets/onboarding_scaffold.dart';

class ProfilePictureScreen extends StatefulWidget {
  const ProfilePictureScreen({
    required this.onContinue,
    super.key,
  });

  final ValueChanged<String> onContinue;

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  String? _photoPath;

  Future<void> _pickPhoto() async {
    // Compress on-device before upload: image_picker downscales to fit
    // within 1080×1080 (aspect preserved) and re-encodes JPEG at 85%.
    // A 10 MB / 4000-px camera photo comes out ~150–250 KB after this,
    // which cached_network_image can then downsample per display size.
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (file != null) setState(() => _photoPath = file.path);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progressRatio: OnboardingStep.profilePicture.progressRatio,
      bottomAction: GradientButton(
        label: 'Continue',
        onPressed: _photoPath == null
            ? null
            : () => widget.onContinue(_photoPath!),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 24),
          Text('Profile Picture', textAlign: TextAlign.center, style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              width: 220,
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                image: _photoPath == null
                    ? null
                    : DecorationImage(
                        image: FileImage(File(_photoPath!)),
                        fit: BoxFit.cover,
                      ),
              ),
              child: _photoPath == null
                  ? const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.textSecondary)
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: _pickPhoto,
            child: Text(
              'Upload photo',
              style: AppTextStyles.body.copyWith(color: AppColors.magenta, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            "Let's see that confidence.\nUpload a clear solo shot.",
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
