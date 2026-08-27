import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../models/profile_prompt.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/prompt_list_field.dart';

/// Generic prompt-list step, reused for Favourite Musicians, Movies, and
/// Dishes — they differ only in title and placeholder copy. All three pass
/// [minRequired]/[maxCount] for "show a few, require just one, offer to
/// add more"; omitting them falls back to "all placeholders shown, all
/// required".
class PromptListStepScreen extends StatefulWidget {
  const PromptListStepScreen({
    required this.title,
    required this.placeholders,
    required this.initial,
    required this.onSave,
    required this.progressRatio,
    required this.onContinue,
    super.key,
    int? initialVisibleCount,
    int? minRequired,
    int? maxCount,
  }) : initialVisibleCount = initialVisibleCount ?? placeholders.length,
       minRequired = minRequired ?? placeholders.length,
       maxCount = maxCount ?? placeholders.length;

  final String title;
  final List<String> placeholders;
  final List<ProfilePrompt> initial;
  final ValueChanged<List<ProfilePrompt>> onSave;
  final double progressRatio;
  final VoidCallback onContinue;
  final int initialVisibleCount;
  final int minRequired;
  final int maxCount;

  @override
  State<PromptListStepScreen> createState() => _PromptListStepScreenState();
}

class _PromptListStepScreenState extends State<PromptListStepScreen> {
  late int _visibleCount = widget.initial.length > widget.initialVisibleCount
      ? widget.initial.length
      : widget.initialVisibleCount;
  late final List<ProfilePrompt> _prompts = List<ProfilePrompt>.generate(
    _visibleCount,
    (int i) => widget.initial.length > i
        ? widget.initial[i]
        : ProfilePrompt(index: i + 1, placeholder: widget.placeholders[i]),
  );
  late final List<TextEditingController> _controllers = _prompts
      .map((ProfilePrompt p) => TextEditingController(text: p.answer))
      .toList();

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  int get _filledCount =>
      _prompts.where((p) => p.answer.trim().isNotEmpty).length;

  bool get _canContinue => _filledCount >= widget.minRequired;

  void _addAnother() {
    setState(() {
      final int i = _prompts.length;
      _prompts.add(ProfilePrompt(index: i + 1, placeholder: widget.placeholders[i]));
      _controllers.add(TextEditingController());
      _visibleCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<ProfilePrompt> answered = _prompts
        .where((p) => p.answer.trim().isNotEmpty)
        .toList();

    return OnboardingScaffold(
      progressRatio: widget.progressRatio,
      bottomAction: GradientButton(
        label: 'Continue',
        onPressed: _canContinue
            ? () {
                widget.onSave(answered);
                widget.onContinue();
              }
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 24),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headline,
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < _prompts.length; i++)
            PromptListField(
              prompt: _prompts[i],
              controller: _controllers[i],
              onChanged: (String value) {
                setState(() {
                  _prompts[i] = _prompts[i].copyWith(answer: value);
                });
              },
            ),
          if (_visibleCount < widget.maxCount)
            TextButton.icon(
              onPressed: _addAnother,
              icon: const Icon(Icons.add, color: AppColors.magenta),
              label: Text(
                'Add another',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.magenta,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
