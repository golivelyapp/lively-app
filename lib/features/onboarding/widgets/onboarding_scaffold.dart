import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Shared chrome for every wizard step: back arrow, thin progress track,
/// scrollable body, and a fixed bottom CTA slot.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    required this.child,
    required this.bottomAction,
    super.key,
    this.progressRatio,
    this.onBack,
  });

  final Widget child;
  final Widget bottomAction;
  final double? progressRatio;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.black),
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  if (progressRatio != null) ...<Widget>[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 4,
                          backgroundColor: AppColors.lockChip,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.magenta,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: child,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: bottomAction,
            ),
          ],
        ),
      ),
    );
  }
}
