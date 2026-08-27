import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/chip_option.dart';
import '../../../core/widgets/pill_toggle.dart';

/// Grid of toggleable pills capped at [maxSelected] selections, used for
/// Activities of Interest and My Traits.
class ChipMultiSelect extends StatelessWidget {
  const ChipMultiSelect({
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.maxSelected,
    super.key,
  });

  final List<ChipOption> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final int maxSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((ChipOption option) {
        return PillToggle(
          label: option.label,
          icon: option.icon,
          selected: selected.contains(option.label),
          onTap: () => onToggle(option.label),
        );
      }).toList(),
    );
  }
}
