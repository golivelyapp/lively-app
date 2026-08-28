import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/api/env.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/photo_image_provider.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../onboarding/models/onboarding_draft.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';

/// In preview builds we auto-approve after a short beat so demos can
/// walk all the way to Home without a real admin. Prod keeps this
/// screen up until the admin flips reviewStatus in Supabase.
class AwaitingReviewScreen extends ConsumerStatefulWidget {
  const AwaitingReviewScreen({super.key});
  @override
  ConsumerState<AwaitingReviewScreen> createState() =>
      _AwaitingReviewScreenState();
}

class _AwaitingReviewScreenState extends ConsumerState<AwaitingReviewScreen> {
  Timer? _previewApproveTimer;

  @override
  void initState() {
    super.initState();
    if (Env.previewMode) {
      _previewApproveTimer = Timer(const Duration(seconds: 4), () async {
        if (!mounted) return;
        await ref.read(onboardingDraftProvider.notifier).previewApprove();
        if (mounted) {
          // Force auth-state provider to re-read profile from Supabase
          // so the router notices review_status flipped to approved.
          ref.read(profileRefreshTriggerProvider.notifier).state++;
        }
      });
    }
  }

  @override
  void dispose() {
    _previewApproveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WidgetRef ref = this.ref;
    final OnboardingDraft draft = ref.watch(onboardingDraftProvider);
    final List<MapEntry<String, bool>> checklist = draft.sectionChecklist;
    final List<MapEntry<String, bool>> incomplete = checklist
        .where((e) => !e.value)
        .toList();
    final List<MapEntry<String, bool>> complete = checklist
        .where((e) => e.value)
        .toList();
    final int percent = (draft.completionRatio * 100).round();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            const Icon(Icons.access_time, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.xs),
            const Text('Awaiting Review', style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Your profile is under review. Meanwhile, complete your '
              'profile to be prioritized.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      value: draft.completionRatio,
                      strokeWidth: 4,
                      backgroundColor: AppColors.lockChip,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.pink,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: photoImageProvider(draft.profilePhotoPath),
                    backgroundColor: AppColors.surface,
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 28,
                    child: Icon(Icons.verified, color: AppColors.gold, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(draft.name ?? '', textAlign: TextAlign.center, style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$percent% profile completed',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ChecklistCard(entries: incomplete, complete: false),
            const SizedBox(height: AppSpacing.sm),
            _ChecklistCard(entries: complete, complete: true),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Why we review profiles',
                    style: AppTextStyles.headline.copyWith(color: AppColors.magenta),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    "Lively isn't a feed. It's a room.\n\n"
                    'We review profiles to keep the space high-quality, '
                    'balanced, and real, while filtering out fake accounts '
                    'and bad actors along the way.\n\n'
                    'Clear photos and high-quality write-ups help us '
                    'understand who you are and decide who fits the room.',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: 'Invite friends',
              leadingIcon: const Icon(Icons.share, color: AppColors.textOnDark, size: 18),
              onPressed: () {
                Share.share(
                  "I just joined Lively — a members-only community for meeting people through real events in Bangalore. Grab an invite: https://lively.app",
                  subject: 'Join me on Lively',
                );
              },
            ),
            if (Env.previewMode) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () async {
                  await ref
                      .read(onboardingDraftProvider.notifier)
                      .previewApprove();
                  ref.read(profileRefreshTriggerProvider.notifier).state++;
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.magenta,
                  side: const BorderSide(color: AppColors.magenta),
                ),
                child: const Text('Enter Lively (preview)'),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Auto-approves in a few seconds — this button is only in the preview build.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.entries, required this.complete});

  final List<MapEntry<String, bool>> entries;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          for (final MapEntry<String, bool> entry in entries)
            ListTile(
              title: Text(entry.key, style: AppTextStyles.body),
              trailing: Icon(
                complete ? Icons.check_circle : Icons.error,
                color: complete ? AppColors.black : AppColors.error,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
