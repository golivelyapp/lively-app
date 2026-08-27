import 'package:flutter/material.dart';
import '../data/bangalore_localities.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Bottom sheet used both in onboarding Basics and the Home location pill,
/// so the two entry points can never present different choices.
///
/// Returns the newly-chosen locality or null if dismissed. The special
/// value returned when the user taps "Use current location" is the
/// currently detected locality — passed in via [detectedLocality] and
/// defaulted to the first entry in [bangaloreLocalities].
Future<String?> showLocalityPickerSheet(
  BuildContext context, {
  required String selected,
  String? detectedLocality,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (BuildContext ctx) => _LocalitySheet(
      selected: selected,
      detected: detectedLocality ?? bangaloreLocalities.first,
    ),
  );
}

class _LocalitySheet extends StatefulWidget {
  const _LocalitySheet({required this.selected, required this.detected});
  final String selected;
  final String detected;
  @override
  State<_LocalitySheet> createState() => _LocalitySheetState();
}

class _LocalitySheetState extends State<_LocalitySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.75;
    final String q = _query.trim().toLowerCase();
    final List<String> matches = q.isEmpty
        ? bangaloreLocalities
        : bangaloreLocalities.where((l) => l.toLowerCase().contains(q)).toList();

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('Choose your area', style: AppTextStyles.headline),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search localities',
                    prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                onTap: () => Navigator.of(context).pop(widget.detected),
                leading: const Icon(Icons.my_location, color: AppColors.magenta),
                title: Text(
                  'Use current location',
                  style: AppTextStyles.body.copyWith(color: AppColors.magenta, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(widget.detected, style: AppTextStyles.caption),
              ),
              const Divider(height: 1, color: AppColors.border),
              Flexible(
                child: matches.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text('No matches for "$_query"', style: AppTextStyles.bodySecondary),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: matches.length,
                        itemBuilder: (context, i) {
                          final String label = matches[i];
                          final bool active = label == widget.selected;
                          return ListTile(
                            onTap: () => Navigator.of(context).pop(label),
                            title: Text(
                              label,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                                color: active ? AppColors.magenta : AppColors.textPrimary,
                              ),
                            ),
                            trailing: active
                                ? const Icon(Icons.check, color: AppColors.magenta, size: 20)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
