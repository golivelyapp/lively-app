import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../models/chip_option.dart';
import '../widgets/chip_multi_select.dart';
import '../widgets/onboarding_scaffold.dart';

/// Generic exactly-N chip picker, reused for Activities of Interest and
/// My Traits.
class ChipSelectStepScreen extends StatefulWidget {
  const ChipSelectStepScreen({
    required this.title,
    required this.options,
    required this.maxSelected,
    required this.initial,
    required this.progressRatio,
    required this.onContinue,
    super.key,
  });

  final String title;
  final List<ChipOption> options;
  final int maxSelected;
  final Set<String> initial;
  final double progressRatio;
  final ValueChanged<Set<String>> onContinue;

  @override
  State<ChipSelectStepScreen> createState() => _ChipSelectStepScreenState();
}

class _ChipSelectStepScreenState extends State<ChipSelectStepScreen> {
  late Set<String> _selected = Set<String>.of(widget.initial);

  void _toggle(String label) {
    setState(() {
      final Set<String> next = Set<String>.of(_selected);
      if (next.contains(label)) {
        next.remove(label);
      } else if (next.length < widget.maxSelected) {
        next.add(label);
      }
      _selected = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progressRatio: widget.progressRatio,
      bottomAction: GradientButton(
        label: 'Continue',
        onPressed: _selected.length == widget.maxSelected
            ? () => widget.onContinue(_selected)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 24),
          Text(widget.title, textAlign: TextAlign.center, style: AppTextStyles.headline),
          Text('Pick any ${widget.maxSelected}', textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 24),
          ChipMultiSelect(
            options: widget.options,
            selected: _selected,
            maxSelected: widget.maxSelected,
            onToggle: _toggle,
          ),
        ],
      ),
    );
  }
}
