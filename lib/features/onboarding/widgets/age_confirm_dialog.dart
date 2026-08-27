import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Age is irreversible once confirmed — shown right before a Basics
/// submission that includes a date of birth.
Future<bool> showAgeConfirmDialog(BuildContext context, int age) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text('Are you $age years old?', style: AppTextStyles.headline),
        content: const Text(
          'Make sure that the age you entered is correct. This cannot be '
          'changed later.',
          style: AppTextStyles.body,
        ),
        actionsPadding: const EdgeInsets.all(AppSpacing.md),
        // A single Row so Expanded has the Flex ancestor it needs —
        // AlertDialog.actions itself lays children out via OverflowBar,
        // which is not a Flex and silently fails to render Expanded
        // children (shows as a blank dialog in release builds).
        actions: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      );
    },
  ).then((bool? value) => value ?? false);
}
