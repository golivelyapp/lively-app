import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../models/profile_prompt.dart';
import '../widgets/onboarding_scaffold.dart';

const List<String> _platforms = <String>[
  'instagram.com/',
  'linkedin.com/',
  'x.com/',
];

class SocialsScreen extends StatefulWidget {
  const SocialsScreen({
    required this.initial,
    required this.onContinue,
    super.key,
  });

  final List<SocialLink> initial;
  final ValueChanged<List<SocialLink>> onContinue;

  @override
  State<SocialsScreen> createState() => _SocialsScreenState();
}

class _SocialsScreenState extends State<SocialsScreen> {
  late final List<TextEditingController> _controllers = _platforms.map((p) {
    final SocialLink? existing = widget.initial
        .where((s) => s.platform == p)
        .firstOrNull;
    return TextEditingController(text: existing?.handle ?? '');
  }).toList();
  late List<bool> _display = List<bool>.generate(_platforms.length, (int i) {
    final SocialLink? existing = widget.initial
        .where((s) => s.platform == _platforms[i])
        .firstOrNull;
    return existing?.displayOnProfile ?? true;
  });

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canContinue =>
      _controllers.any((TextEditingController c) => c.text.trim().isNotEmpty);

  void _handleContinue() {
    final List<SocialLink> links = <SocialLink>[
      for (int i = 0; i < _platforms.length; i++)
        if (_controllers[i].text.trim().isNotEmpty)
          SocialLink(
            platform: _platforms[i],
            handle: _controllers[i].text.trim(),
            displayOnProfile: _display[i],
          ),
    ];
    widget.onContinue(links);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      bottomAction: GradientButton(
        label: 'Continue',
        onPressed: _canContinue ? _handleContinue : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 24),
          Text('Enter Your Socials', textAlign: TextAlign.center, style: AppTextStyles.headline),
          const Text('Add at least 1', textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 24),
          for (int i = 0; i < _platforms.length; i++) ...<Widget>[
            TextField(
              controller: _controllers[i],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                // A fixed prefix, not a hint — hints vanish the moment you
                // type, which made it look like the platform name got
                // overwritten instead of the handle just following it.
                // Uses `prefix` (a widget slot), not `prefixText`: the
                // latter silently fails to paint when combined with
                // `hintText` on an empty, unfocused field.
                prefix: Text(
                  _platforms[i],
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                hintText: 'username',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: <Widget>[
                  const Text('Display it on your profile', style: AppTextStyles.bodySecondary),
                  const Spacer(),
                  Switch(
                    value: _display[i],
                    onChanged: (bool v) => setState(() {
                      _display = List<bool>.of(_display)..[i] = v;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
