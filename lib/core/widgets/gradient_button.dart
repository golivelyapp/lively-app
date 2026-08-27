import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// The warm coral-to-magenta CTA used for every primary action:
/// Get started, purchase packs, Continue with Plus, etc.
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.cta,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            onTap: onPressed,
            child: SizedBox(
              height: 52,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (leadingIcon != null) ...<Widget>[
                      leadingIcon!,
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(label, style: AppTextStyles.button),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
