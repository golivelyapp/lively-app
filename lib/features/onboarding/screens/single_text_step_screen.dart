import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../widgets/onboarding_scaffold.dart';

/// Generic single free-text step. Used for "Hear Me Out" (bio).
class SingleTextStepScreen extends StatefulWidget {
  const SingleTextStepScreen({
    required this.title,
    required this.hint,
    required this.maxLength,
    required this.initial,
    required this.onSave,
    required this.progressRatio,
    required this.onContinue,
    super.key,
  });

  final String title;
  final String hint;
  final int maxLength;
  final String initial;
  final ValueChanged<String> onSave;
  final double progressRatio;
  final VoidCallback onContinue;

  @override
  State<SingleTextStepScreen> createState() => _SingleTextStepScreenState();
}

class _SingleTextStepScreenState extends State<SingleTextStepScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  late String _value = widget.initial;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progressRatio: widget.progressRatio,
      bottomAction: GradientButton(
        label: 'Continue',
        onPressed: _value.trim().isEmpty
            ? null
            : () {
                widget.onSave(_value);
                widget.onContinue();
              },
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
          TextField(
            controller: _controller,
            maxLength: widget.maxLength,
            maxLines: 6,
            onChanged: (String v) => setState(() => _value = v),
            style: AppTextStyles.body,
            decoration: InputDecoration(hintText: widget.hint),
          ),
        ],
      ),
    );
  }
}
