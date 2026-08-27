import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class GenderBalanceBar extends StatelessWidget {
  const GenderBalanceBar({required this.maleRatio, super.key, this.height = 4});

  final double maleRatio;
  final double height;

  /// Soft green for women (left), soft blue for men (right).
  static const Color womenColor = AppColors.balanceWomen;
  static const Color menColor = AppColors.balanceMen;

  @override
  Widget build(BuildContext context) {
    final int menFlex = (maleRatio * 1000).round().clamp(0, 1000);
    final int womenFlex = 1000 - menFlex;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: SizedBox(
        height: height,
        child: Row(
          children: <Widget>[
            if (womenFlex > 0)
              Expanded(flex: womenFlex, child: const ColoredBox(color: womenColor)),
            if (menFlex > 0)
              Expanded(flex: menFlex, child: const ColoredBox(color: menColor)),
          ],
        ),
      ),
    );
  }
}
