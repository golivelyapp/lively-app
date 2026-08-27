import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/env.dart';
import '../../features/auth/providers/auth_state_provider.dart';
import '../../features/auth/screens/login_screen.dart';
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
      if (location == RoutePaths.splash) {
        if (status == AuthStatus.authenticated) return RoutePaths.home;
        return null;
      }

      final bool onLogin = location == RoutePaths.login;
      final bool onOnboarding = location.startsWith('/onboarding');

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
        return location == RoutePaths.awaitingReview
            ? null
            : RoutePaths.awaitingReview;
      }
      if (onLogin || onOnboarding || location == RoutePaths.awaitingReview) {
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
            final controller = ref.read(onboardingDraftProvider.notifier);
            return BasicsScreen(
              onContinue: ({
                required name,
                required dateOfBirth,
                required location,
                required gender,
              }) {
                controller.updateBasics(
                  name: name,
                  dateOfBirth: dateOfBirth,
                  location: location,
                  gender: gender,
                );
                context.push(RoutePaths.onboardingProfilePicture);
              },
            );
          },
        ),
      ),
      GoRoute(
        path: RoutePaths.onboardingProfilePicture,
        builder: (BuildContext context, __) => Consumer(
          builder: (context, ref, __) => ProfilePictureScreen(
            onContinue: (String path) {
              ref.read(onboardingDraftProvider.notifier).setProfilePhoto(path);
              context.push(RoutePaths.onboardingActivities);
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
              onContinue: (Set<String> selected) {
                ref.read(onboardingDraftProvider.notifier).setActivities(selected);
                context.push(RoutePaths.onboardingBio);
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
            onSave: ref.read(onboardingDraftProvider.notifier).updateBio,
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
              final controller = ref.read(onboardingDraftProvider.notifier);
              controller.setSelfiePhoto(path);
              await controller.submit();
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
