import 'package:flutter/material.dart';
import '../../../core/data/bangalore_localities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/locality_picker_sheet.dart';
import '../../../core/widgets/pill_toggle.dart';
import '../models/onboarding_enums.dart';
import '../models/onboarding_step.dart';
import '../widgets/dob_input_field.dart';
import '../widgets/onboarding_scaffold.dart';

class BasicsScreen extends StatefulWidget {
  const BasicsScreen({required this.onContinue, super.key});

  final void Function({
    required String name,
    required DateTime dateOfBirth,
    required String location,
    required Gender gender,
  }) onContinue;

  @override
  State<BasicsScreen> createState() => _BasicsScreenState();
}

class _BasicsScreenState extends State<BasicsScreen> {
  final TextEditingController _name = TextEditingController();
  DateTime? _dob;
  Gender? _gender;
  // Auto-detected default — real GPS would populate this; we default to
  // the same locality the Home screen would show for a fresh install.
  String _location = 'Koramangala';
  bool _autoDetected = true;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _name.text.trim().isNotEmpty && _dob != null && _gender != null;

  Future<void> _changeLocation() async {
    final String? picked = await showLocalityPickerSheet(
      context,
      selected: _location,
    );
    if (picked != null) {
      setState(() {
        _location = picked;
        _autoDetected = false;
      });
    }
  }

  void _handleContinue() {
    // The DobInputField already enforces the 18+ gate + valid-date rules,
    // so we don't need a separate confirmation dialog here — the field
    // itself shows the error inline. Age check happens BEFORE this fires.
    widget.onContinue(
      name: _name.text.trim(),
      dateOfBirth: _dob!,
      location: _location,
      gender: _gender!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progressRatio: OnboardingStep.basics.progressRatio,
      bottomAction: GradientButton(
        label: 'Continue',
        onPressed: _canContinue ? _handleContinue : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 8),
          Text('Your Basics', textAlign: TextAlign.center, style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.lg),
          _Field(label: 'Name', controller: _name, onChanged: (_) => setState(() {})),
          DobInputField(
            initial: _dob,
            onChanged: (DateTime? d) => setState(() => _dob = d),
          ),
          _LocationField(
            location: _location,
            autoDetected: _autoDetected,
            onChange: _changeLocation,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('Gender', style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            children: Gender.values.map((Gender g) {
              return PillToggle(
                label: g.label,
                selected: _gender == g,
                onTap: () => setState(() => _gender = g),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, required this.onChanged, this.hint});
  final String label;
  final TextEditingController controller;
  final String? hint;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(label, style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}


class _LocationField extends StatelessWidget {
  const _LocationField({required this.location, required this.autoDetected, required this.onChange});
  final String location;
  final bool autoDetected;
  final VoidCallback onChange;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Location', style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            onTap: onChange,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InputDecorator(
              decoration: const InputDecoration(),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.place_outlined, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(location, style: AppTextStyles.body),
                  ),
                  Text(
                    autoDetected ? 'Change' : 'Change',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.magenta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (autoDetected) ...<Widget>[
            const SizedBox(height: 4),
            Text('Auto-detected from your location', style: AppTextStyles.caption),
          ],
        ],
      ),
    );
  }
}
