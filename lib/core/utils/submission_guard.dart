import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Wraps an async action with (a) a blocking loading overlay so the
/// user can't double-tap, (b) proper error surfacing via SnackBar,
/// (c) safe navigation guarding for context.mounted after the await.
///
/// Returns true iff the action completed without throwing. Callers
/// should ONLY navigate forward when true — otherwise stay on the
/// current screen so the user can retry.
Future<bool> runGuarded(
  BuildContext context, {
  required Future<void> Function() action,
  String? loadingLabel,
  String? errorPrefix,
}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (_) => _LoadingOverlay(label: loadingLabel ?? 'Saving…'),
  );
  try {
    await action();
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    return true;
  } catch (e, st) {
    // ignore: avoid_print
    print('runGuarded failed: $e\n$st');
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_shortError(errorPrefix, e)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    return false;
  }
}

String _shortError(String? prefix, Object e) {
  final String base = prefix ?? "Something went wrong";
  final String msg = e.toString();
  // Trim overly long stack-like messages.
  final String short = msg.length > 180 ? '${msg.substring(0, 180)}…' : msg;
  return '$base — $short';
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.magenta),
              ),
            ),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
