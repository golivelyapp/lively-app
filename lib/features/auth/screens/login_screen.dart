import 'dart:async';
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

class _LoginScreenState extends ConsumerState<LoginScreen>
    with WidgetsBindingObserver {
  bool _signingIn = false;
  String _provider = '';
  Timer? _timeoutTimer;
  Timer? _resumeGraceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _resumeGraceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the OAuth browser tab closes and the app returns to
    // foreground, give Supabase a 3s grace window to process the
    // callback and create a session. If no session materialises, the
    // user cancelled (or OAuth failed silently) — clear the spinner
    // instead of hanging forever.
    if (state == AppLifecycleState.resumed && _signingIn) {
      _resumeGraceTimer?.cancel();
      _resumeGraceTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        final Session? session =
            SupabaseService.client.auth.currentSession;
        if (session == null) {
          _cancelSignIn(reason: 'Sign-in cancelled.');
        }
        // If session != null, the auth-state stream fires and the
        // router unmounts this screen — no cleanup needed.
      });
    }
  }

  void _cancelSignIn({String? reason}) {
    _timeoutTimer?.cancel();
    _resumeGraceTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _signingIn = false;
      _provider = '';
    });
    if (reason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reason),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signIn(OAuthProvider provider, String label) async {
    if (_signingIn) return;
    setState(() {
      _signingIn = true;
      _provider = label;
    });

    // Hard 45-second ceiling. If we're still waiting after that,
    // something went wrong (network, verification blocking the flow,
    // user forgot) — reset the UI so they can try again.
    _timeoutTimer = Timer(const Duration(seconds: 45), () {
      _cancelSignIn(reason: 'Sign-in took too long. Please try again.');
    });

    try {
      await SupabaseService.client.auth.signInWithOAuth(
        provider,
        redirectTo: Env.authRedirectUrl,
        // launchMode picks an external browser on Android so the OAuth
        // consent tab looks legit; falling back to in-app WebView breaks
        // Google's account-picker for security reasons.
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      _cancelSignIn(reason: 'Sign-in failed: $e');
    }
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
              if (_signingIn) _SigningInOverlay(onCancel: () => _cancelSignIn()),
            ],
          ),
        ),
      ),
    );
  }
}

class _SigningInOverlay extends StatelessWidget {
  const _SigningInOverlay({required this.onCancel});
  final VoidCallback onCancel;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withOpacity(0.35),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnDark),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Waiting for Google…', style: AppTextStyles.body.copyWith(color: AppColors.textOnDark)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Times out automatically in 45s',
                style: AppTextStyles.caption.copyWith(color: AppColors.textOnDark.withOpacity(0.85)),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  foregroundColor: AppColors.textOnDark,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
                child: const Text('Cancel'),
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
