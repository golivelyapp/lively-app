import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';

class OnboardingIntroScreen extends StatelessWidget {
  const OnboardingIntroScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              IconButton(
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back, color: AppColors.black),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              Text(
                'Lively',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayLg.copyWith(color: AppColors.magenta),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Lively is a members-only community where you discover and '
                'join real-world activities — art jams, pub quizzes, lake '
                'walks, and more — with verified people near you.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const Spacer(),
              GradientButton(label: 'Continue', onPressed: onContinue),
            ],
          ),
        ),
      ),
    );
  }
}
