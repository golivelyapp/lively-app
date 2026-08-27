import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/pill_toggle.dart';
import '../models/event_category.dart';

class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    required this.selected,
    required this.categories,
    required this.onSelected,
    super.key,
  });

  final String selected;
  final List<EventCategory> categories;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: PillToggle(
              label: 'All',
              selected: selected == 'all',
              onTap: () => onSelected('all'),
            ),
          ),
          for (final EventCategory category in categories)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: PillToggle(
                label: category.label,
                icon: category.icon,
                selected: selected == category.name,
                onTap: () => onSelected(category.name),
              ),
            ),
        ],
      ),
    );
  }
}
