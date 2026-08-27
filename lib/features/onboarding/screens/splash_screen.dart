import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/constellation_graphic.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({required this.onTapStart, super.key});

  final VoidCallback onTapStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.marketingBackground),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapStart,
          child: SafeArea(
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(flex: 3),
                  const ConstellationGraphic().animate().fadeIn(
                    duration: 700.ms,
                    curve: Curves.easeOutCubic,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'lively',
                        style: AppTextStyles.displayLg.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 40,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6, left: 2),
                        child: _Dot(),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'NOBODY HERE IS A STRANGER',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnDark.withOpacity(0.7),
                      letterSpacing: 3,
                    ),
                  ).animate().fadeIn(delay: 350.ms, duration: 600.ms),
                  const Spacer(flex: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: Text(
                      'TAP TO START',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnDark,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(
                      duration: 900.ms,
                      begin: 0.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.textOnDark,
        shape: BoxShape.circle,
      ),
    );
  }
}
