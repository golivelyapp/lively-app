import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/constellation_graphic.dart';
import '../../auth/providers/auth_state_provider.dart';

/// Marketing splash. Watches auth state so returning users (session is
/// being restored on cold start → `AuthStatus.loading`) never see the
/// "TAP TO START" prompt — they see a bare logo screen for a beat while
/// the router waits for the profile to resolve, then land directly on
/// their real destination.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({required this.onTapStart, super.key});

  final VoidCallback onTapStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthStatus status = ref.watch(authStateProvider);
    // Show the tap-to-start prompt (and enable the gesture) only when the
    // user is definitively signed out. During `loading` (session-restore
    // in progress) any other status the router will forward us anyway;
    // showing the prompt would be a false invitation to a returning user.
    final bool showTapPrompt = status == AuthStatus.unauthenticated;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.marketingBackground),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: showTapPrompt ? onTapStart : null,
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
                    child: showTapPrompt
                        ? Text(
                            'TAP TO START',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textOnDark,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                            .animate(
                                onPlay: (c) => c.repeat(reverse: true))
                            .fadeIn(duration: 900.ms, begin: 0.35)
                        : const SizedBox.shrink(),
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
