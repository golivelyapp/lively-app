import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/auth_state_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _signingIn = false;
  String _provider = '';

  Future<void> _signIn(String provider) async {
    if (_signingIn) return;
    setState(() {
      _signingIn = true;
      _provider = provider;
    });
    // Simulate the OAuth round-trip so the transition feels intentional
    // instead of an instant jump. Once real Supabase OAuth is wired,
    // this becomes an actual awaited network call.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    ref.read(stubSignedInProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.marketingBackground),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Spacer(),
                  const Text(
                    'Lively',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textOnDark,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _ProviderButton(
                          label: 'Log in via Google',
                          icon: Icons.g_mobiledata,
                          loading: _signingIn && _provider == 'google',
                          disabled: _signingIn,
                          onPressed: () => _signIn('google'),
                        ),
                        if (Platform.isIOS) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          _ProviderButton(
                            label: 'Log in via Apple account',
                            icon: Icons.apple,
                            loading: _signingIn && _provider == 'apple',
                            disabled: _signingIn,
                            onPressed: () => _signIn('apple'),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'By continuing, you agree to our Terms & Privacy Policy',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textOnDark.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_signingIn)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withOpacity(0.25),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnDark),
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text('Signing you in…', style: AppTextStyles.body),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.disabled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final bool disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.background.withOpacity(0.7),
        ),
        onPressed: disabled ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                ),
              )
            : Icon(icon),
        label: Text(label, style: AppTextStyles.button.copyWith(color: AppColors.textPrimary)),
      ),
    );
  }
}
