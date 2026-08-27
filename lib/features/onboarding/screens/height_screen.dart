import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../widgets/onboarding_scaffold.dart';

// The wheel steps in whole inches, not centimeters — stepping by
// centimeters made several adjacent rows round to the identical
// feet'inches label (e.g. "5'9"" showing twice in a row).
const int _minTotalInches = 55; // 4'7"
const int _maxTotalInches = 83; // 6'11"
const int _defaultTotalInches = 68; // 5'8"

String _formatFeetInches(int totalInches) {
  final int feet = totalInches ~/ 12;
  final int inches = totalInches % 12;
  return "$feet'$inches\"";
}

int _inchesToCm(int totalInches) => (totalInches * 2.54).round();

class HeightScreen extends StatefulWidget {
  const HeightScreen({required this.onContinue, super.key});

  final ValueChanged<int> onContinue;

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  int _selectedTotalInches = _defaultTotalInches;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      bottomAction: GradientButton(
        label: 'Continue',
        onPressed: () => widget.onContinue(_inchesToCm(_selectedTotalInches)),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 24),
          Text('Height', textAlign: TextAlign.center, style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.xs),
          const Text('Scroll to pick', style: AppTextStyles.bodySecondary),
          SizedBox(
            height: 280,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 56,
              perspective: 0.003,
              diameterRatio: 1.6,
              physics: const FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(
                initialItem: _selectedTotalInches - _minTotalInches,
              ),
              onSelectedItemChanged: (int index) {
                setState(() => _selectedTotalInches = _minTotalInches + index);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _maxTotalInches - _minTotalInches + 1,
                builder: (BuildContext context, int index) {
                  final int totalInches = _minTotalInches + index;
                  final bool selected = totalInches == _selectedTotalInches;
                  return Center(
                    child: Text(
                      _formatFeetInches(totalInches),
                      style: selected
                          ? AppTextStyles.headline
                          : AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
