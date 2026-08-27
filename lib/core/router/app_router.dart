import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/env.dart';
import 'dart:io';
import '../../features/auth/providers/auth_state_provider.dart';
import '../../features/auth/repositories/profile_repository.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/onboarding/models/onboarding_enums.dart';
import '../../features/onboarding/models/onboarding_options.dart';
import '../../features/onboarding/models/onboarding_step.dart';
import '../../features/onboarding/providers/onboarding_draft_controller.dart';
import '../../features/onboarding/screens/basics_screen.dart';
import '../../features/onboarding/screens/chip_select_step_screen.dart';
import '../../features/onboarding/screens/intro_screen.dart';
import '../../features/onboarding/screens/profile_picture_screen.dart';
import '../../features/onboarding/screens/selfie_verification_screen.dart';
import '../../features/onboarding/screens/single_text_step_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/chats/screens/chats_screen.dart';
import '../../features/chats/screens/event_chat_screen.dart';
import '../../features/home/screens/event_detail_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/people/screens/people_screen.dart';
import '../../features/profile/screens/awaiting_review_screen.dart';
import '../../features/profile/screens/create_event_screen.dart';
import '../../features/profile/screens/host_verification_screen.dart';
import '../../features/profile/screens/profile_enhance_screens.dart';
import '../../features/profile/screens/you_screen.dart';
import 'main_shell.dart';
import 'route_paths.dart';

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._status);
  AuthStatus _status;
  AuthStatus get status => _status;
  void update(AuthStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier(ref.read(authStateProvider));
  ref.listen<AuthStatus>(authStateProvider, (_, next) {
    authNotifier.update(next);
  });

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStatus status = authNotifier.status;
      final String location = state.matchedLocation;

      final bool onSplash = location == RoutePaths.splash;
      final bool onLogin = location == RoutePaths.login;
      final bool onOnboarding = location.startsWith('/onboarding');
      final bool onAwaiting = location == RoutePaths.awaitingReview;

      // Splash is a tap-to-continue gate ONLY for a fresh install with
      // no session yet. Once the user has any status, splash must
      // forward them to their proper destination — otherwise a deep
      // link back from Google OAuth cold-starts the app on splash and
      // the user gets stuck.
      if (onSplash) {
        return switch (status) {
          AuthStatus.unauthenticated => null,
          AuthStatus.onboarding => RoutePaths.onboardingIntro,
          AuthStatus.awaitingReview => RoutePaths.awaitingReview,
          AuthStatus.authenticated => RoutePaths.home,
        };
      }

      if (status == AuthStatus.unauthenticated) {
        return onLogin ? null : RoutePaths.login;
      }
      if (status == AuthStatus.onboarding) {
        return onOnboarding ? null : RoutePaths.onboardingIntro;
      }
      if (status == AuthStatus.awaitingReview) {
        // While under review the user can't reach the tabbed app —
        // they're pinned on Awaiting Review and the nav bar isn't
        // rendered (MainShell only appears for authenticated users).
        return onAwaiting ? null : RoutePaths.awaitingReview;
      }
      // Approved: bounce anyone on login/onboarding/review back to Home.
      if (onLogin || onOnboarding || onAwaiting) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.splash,
        builder: (BuildContext context, __) => SplashScreen(
          onTapStart: () => context.go(RoutePaths.login),
        ),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingIntro,
        builder: (BuildContext context, __) => OnboardingIntroScreen(
          onContinue: () => context.push(RoutePaths.onboardingBasics),
        ),
      ),
      GoRoute(
        path: RoutePaths.onboardingBasics,
        builder: (BuildContext context, __) => Consumer(
          builder: (context, ref, __) {
            return BasicsScreen(
              onContinue: ({
                required name,
                required dateOfBirth,
                required location,
                required gender,
              }) async {
                final repo = ref.read(profileRepositoryProvider);
                // Look up city + locality UUIDs from the shared name
                // string the picker returned.
                final String cityId = await repo.defaultCityId();
                final localities = await repo.fetchLocalities();
                final match = localities.firstWhere(
                  (l) => l['name'] == location,
                  orElse: () => localities.first,
                );
                await repo.updateBasics(
                  name: name,
                  dateOfBirth: dateOfBirth,
                  gender: gender.name,   // Gender enum → 'male'|'female'|'other'
                  cityId: cityId,
                  localityId: match['id'] as String,
                );
                // Keep the local draft in sync so downstream screens
                // that still read from it show the right values.
                ref.read(onboardingDraftProvider.notifier).updateBasics(
                      name: name,
                      dateOfBirth: dateOfBirth,
                      location: location,
                      gender: gender,
                    );
                ref.read(profileRefreshTriggerProvider.notifier).state++;
                if (context.mounted) context.push(RoutePaths.onboardingProfilePicture);
              },
            );
          },
        ),
      ),
      GoRoute(
        path: RoutePaths.onboardingProfilePicture,
        builder: (BuildContext context, __) => Consumer(
          builder: (context, ref, __) => ProfilePictureScreen(
            onContinue: (String path) async {
              final repo = ref.read(profileRepositoryProvider);
              final uid = ref.read(sessionProvider)!.user.id;
              await repo.uploadPhoto(
                file: File(path),
                bucket: 'avatars',
                purpose: 'avatar',
                ownerType: 'profile',
                ownerId: uid,
              );
              ref.read(onboardingDraftProvider.notifier).setProfilePhoto(path);
              ref.read(profileRefreshTriggerProvider.notifier).state++;
              if (context.mounted) context.push(RoutePaths.onboardingActivities);
            },
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.onboardingActivities,
        builder: (BuildContext context, __) => Consumer(
          builder: (context, ref, __) {
            final draft = ref.watch(onboardingDraftProvider);
            return ChipSelectStepScreen(
              title: 'Activities of Interest',
              options: activityOptions,
              maxSelected: maxActivitySelection,
              initial: draft.activities,
              progressRatio: OnboardingStep.activities.progressRatio,
              onContinue: (Set<String> selected) async {
                final repo = ref.read(profileRepositoryProvider);
                // Convert chip labels ("Board Games") to activity_category
                // UUIDs. Unknown labels are silently dropped.
                final cats = await repo.fetchActivityCategories();
                final Map<String, String> labelToId = <String, String>{
                  for (final c in cats) c['label'] as String: c['id'] as String,
                };
                final List<String> ids = selected
                    .map((label) => labelToId[label])
                    .whereType<String>()
                    .toList();
                await repo.setActivities(ids);
                ref.read(onboardingDraftProvider.notifier).setActivities(selected);
                ref.read(profileRefreshTriggerProvider.notifier).state++;
                if (context.mounted) context.push(RoutePaths.onboardingBio);
              },
            );
          },
        ),
      ),
      GoRoute(
        path: RoutePaths.onboardingBio,
        builder: (BuildContext context, __) => Consumer(
          builder: (context, ref, __) => SingleTextStepScreen(
            title: 'Hear Me Out',
            hint: 'Tell people what makes you, you.',
            maxLength: 300,
            initial: ref.watch(onboardingDraftProvider).bio ?? '',
            progressRatio: OnboardingStep.bio.progressRatio,
            onSave: (String bio) async {
              await ref.read(profileRepositoryProvider).setBio(bio);
              ref.read(onboardingDraftProvider.notifier).updateBio(bio);
              ref.read(profileRefreshTriggerProvider.notifier).state++;
            },
            onContinue: () => context.push(RoutePaths.onboardingSelfieVerification),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.onboardingSelfieVerification,
        builder: (BuildContext context, __) => Consumer(
          builder: (context, ref, __) => SelfieVerificationScreen(
            profilePhotoPath:
                ref.watch(onboardingDraftProvider).profilePhotoPath!,
            onContinue: (String path) async {
              final repo = ref.read(profileRepositoryProvider);
              final uid = ref.read(sessionProvider)!.user.id;
              // Selfie goes to the private verifications bucket — only
              // the owner + admins can read it (RLS enforced).
              await repo.uploadPhoto(
                file: File(path),
                bucket: 'verifications',
                purpose: 'selfie',
                ownerType: 'profile',
                ownerId: uid,
              );
              await repo.submitForReview();
              ref.read(onboardingDraftProvider.notifier).setSelfiePhoto(path);
              // Force the profile to re-read from the DB so the auth
              // state provider notices review_status flipped to 'submitted'.
              ref.read(profileRefreshTriggerProvider.notifier).state++;
              // The router redirect will forward us to /awaiting-review
              // as soon as the new status propagates; explicit go() as
              // a safety net.
              if (context.mounted) context.go(RoutePaths.awaitingReview);
            },
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.awaitingReview,
        builder: (_, __) => const AwaitingReviewScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.home,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.people,
                builder: (_, __) => const PeopleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.chats,
                builder: (_, __) => const ChatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.you,
                builder: (_, __) => const YouScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.eventDetailPattern,
        builder: (BuildContext context, GoRouterState state) =>
            EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.eventChatPattern,
        builder: (BuildContext context, GoRouterState state) =>
            EventChatScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.createEvent,
        builder: (_, __) => const CreateEventScreen(),
      ),
      GoRoute(
        path: RoutePaths.hostVerification,
        builder: (_, __) => const HostVerificationScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileEditHeight,
        builder: (_, __) => const ProfileEditHeightScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileEditTraits,
        builder: (_, __) => const ProfileEditTraitsScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileEditWork,
        builder: (_, __) => const ProfileEditWorkScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileEditMusicians,
        builder: (_, __) => const ProfileEditMusiciansScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileEditMovies,
        builder: (_, __) => const ProfileEditMoviesScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileEditDishes,
        builder: (_, __) => const ProfileEditDishesScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileEditSocials,
        builder: (_, __) => const ProfileEditSocialsScreen(),
      ),
    ],
  );
});
