import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/env.dart';
import '../../../core/api/supabase_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _signingIn = false;
  String _provider = '';

  Future<void> _signIn(OAuthProvider provider, String label) async {
    if (_signingIn) return;
    setState(() {
      _signingIn = true;
      _provider = label;
    });
    try {
      // Opens the browser (Chrome custom tab) to the provider's consent
      // screen. After the user authorises, Supabase redirects to
      // lively://login-callback/ which the Android intent filter catches
      // and returns the app to the foreground with a session.
      await SupabaseService.client.auth.signInWithOAuth(
        provider,
        redirectTo: Env.authRedirectUrl,
        // launchMode picks an external browser on Android so the OAuth
        // consent tab looks legit; falling back to in-app WebView breaks
        // Google's account-picker for security reasons.
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    // We don't clear _signingIn here — the router redirects away on
    // AuthStateChange, unmounting this screen. If the user hits the
    // browser Back button we reset on resume.
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
                          onPressed: () => _signIn(OAuthProvider.google, 'google'),
                        ),
                        if (Platform.isIOS) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          _ProviderButton(
                            label: 'Log in via Apple account',
                            icon: Icons.apple,
                            loading: _signingIn && _provider == 'apple',
                            disabled: _signingIn,
                            onPressed: () => _signIn(OAuthProvider.apple, 'apple'),
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
                  child: GestureDetector(
                    // Tap the overlay to cancel — useful if the user
                    // aborted the browser and came back.
                    onTap: () => setState(() => _signingIn = false),
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
                            Text('Waiting for Google…', style: AppTextStyles.body),
                            SizedBox(height: AppSpacing.xs),
                            Text('Tap anywhere to cancel', style: AppTextStyles.caption),
                          ],
                        ),
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
