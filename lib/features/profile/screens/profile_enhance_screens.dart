import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/pill_toggle.dart';
import '../../onboarding/models/favourite_prompt_examples.dart';
import '../../onboarding/models/onboarding_enums.dart';
import '../../onboarding/models/onboarding_options.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';
import '../../onboarding/screens/chip_select_step_screen.dart';
import '../../onboarding/screens/height_screen.dart';
import '../../onboarding/screens/prompt_list_step_screen.dart';
import '../../onboarding/screens/socials_screen.dart';

class ProfileEditHeightScreen extends ConsumerWidget {
  const ProfileEditHeightScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HeightScreen(
      onContinue: (int cm) {
        ref.read(onboardingDraftProvider.notifier).setHeightCm(cm);
        Navigator.of(context).pop();
      },
    );
  }
}

class ProfileEditTraitsScreen extends ConsumerWidget {
  const ProfileEditTraitsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Set<String> initial = ref.watch(
      onboardingDraftProvider.select((d) => d.traits),
    );
    return ChipSelectStepScreen(
      title: 'My Traits',
      options: traitOptions,
      maxSelected: maxTraitSelection,
      initial: initial,
      progressRatio: 1.0,
      onContinue: (Set<String> selected) {
        ref.read(onboardingDraftProvider.notifier).setTraits(selected);
        Navigator.of(context).pop();
      },
    );
  }
}

class ProfileEditMusiciansScreen extends ConsumerWidget {
  const ProfileEditMusiciansScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PromptListStepScreen(
      title: 'Favourite Musicians',
      placeholders: favouriteMusicianExamples,
      initial: ref.watch(onboardingDraftProvider).musicians,
      initialVisibleCount: favouritePromptInitialVisible,
      minRequired: 0,
      maxCount: favouritePromptMaxCount,
      progressRatio: 1.0,
      onSave: ref.read(onboardingDraftProvider.notifier).updateMusicians,
      onContinue: () => Navigator.of(context).pop(),
    );
  }
}

class ProfileEditMoviesScreen extends ConsumerWidget {
  const ProfileEditMoviesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PromptListStepScreen(
      title: 'Favourite Movies',
      placeholders: favouriteMovieExamples,
      initial: ref.watch(onboardingDraftProvider).movies,
      initialVisibleCount: favouritePromptInitialVisible,
      minRequired: 0,
      maxCount: favouritePromptMaxCount,
      progressRatio: 1.0,
      onSave: ref.read(onboardingDraftProvider.notifier).updateMovies,
      onContinue: () => Navigator.of(context).pop(),
    );
  }
}

class ProfileEditDishesScreen extends ConsumerWidget {
  const ProfileEditDishesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PromptListStepScreen(
      title: 'Favourite Dishes',
      placeholders: favouriteDishExamples,
      initial: ref.watch(onboardingDraftProvider).dishes,
      initialVisibleCount: favouritePromptInitialVisible,
      minRequired: 0,
      maxCount: favouritePromptMaxCount,
      progressRatio: 1.0,
      onSave: ref.read(onboardingDraftProvider.notifier).updateDishes,
      onContinue: () => Navigator.of(context).pop(),
    );
  }
}

class ProfileEditSocialsScreen extends ConsumerWidget {
  const ProfileEditSocialsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SocialsScreen(
      initial: ref.watch(onboardingDraftProvider).socials,
      onContinue: (socials) {
        ref.read(onboardingDraftProvider.notifier).updateSocials(socials);
        Navigator.of(context).pop();
      },
    );
  }
}

class ProfileEditWorkScreen extends ConsumerStatefulWidget {
  const ProfileEditWorkScreen({super.key});
  @override
  ConsumerState<ProfileEditWorkScreen> createState() => _ProfileEditWorkScreenState();
}

class _ProfileEditWorkScreenState extends ConsumerState<ProfileEditWorkScreen> {
  late final TextEditingController _company = TextEditingController(
    text: ref.read(onboardingDraftProvider).company ?? '',
  );
  late final TextEditingController _profession = TextEditingController(
    text: ref.read(onboardingDraftProvider).profession ?? '',
  );
  RelationshipStatus? _status;

  @override
  void initState() {
    super.initState();
    _status = ref.read(onboardingDraftProvider).status;
  }

  @override
  void dispose() {
    _company.dispose();
    _profession.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(onboardingDraftProvider.notifier).updateMoreAboutYou(
          company: _company.text.trim(),
          profession: _profession.text.trim(),
          status: _status,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Work & Status', style: AppTextStyles.headline),
              const SizedBox(height: AppSpacing.lg),
              const Text('Company or industry', style: AppTextStyles.bodySecondary),
              const SizedBox(height: AppSpacing.xs),
              TextField(controller: _company, decoration: const InputDecoration(hintText: 'Google')),
              const SizedBox(height: AppSpacing.md),
              const Text('Profession', style: AppTextStyles.bodySecondary),
              const SizedBox(height: AppSpacing.xs),
              TextField(controller: _profession, decoration: const InputDecoration(hintText: 'Product Designer')),
              const SizedBox(height: AppSpacing.md),
              const Text('Relationship status', style: AppTextStyles.bodySecondary),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                children: RelationshipStatus.values.map((s) {
                  return PillToggle(
                    label: s.label,
                    selected: _status == s,
                    onTap: () => setState(() => _status = s),
                  );
                }).toList(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GradientButton(label: 'Save', onPressed: _save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
