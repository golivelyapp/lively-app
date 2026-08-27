class RoutePaths {
  const RoutePaths._();

  static const String splash = '/';
  static const String login = '/login';

  static const String onboardingIntro = '/onboarding/intro';
  static const String onboardingBasics = '/onboarding/basics';
  static const String onboardingProfilePicture = '/onboarding/profile-picture';
  static const String onboardingHeight = '/onboarding/height';
  static const String onboardingActivities = '/onboarding/activities';
  static const String onboardingTraits = '/onboarding/traits';
  static const String onboardingMusicians = '/onboarding/musicians';
  static const String onboardingMovies = '/onboarding/movies';
  static const String onboardingBio = '/onboarding/bio';
  static const String onboardingDishes = '/onboarding/dishes';
  static const String onboardingSocials = '/onboarding/socials';
  static const String onboardingSelfieVerification =
      '/onboarding/selfie-verification';

  static const String awaitingReview = '/awaiting-review';

  static const String home = '/home';
  static const String people = '/people';
  static const String chats = '/chats';
  static const String you = '/you';

  static const String eventDetailPattern = '/event/:id';
  static String eventDetail(String id) => '/event/$id';

  static const String eventChatPattern = '/chats/:id';
  static String eventChat(String id) => '/chats/$id';

  static const String createEvent = '/create-event';
  static const String hostVerification = '/host-verification';

  static const String profileEditHeight = '/profile/edit/height';
  static const String profileEditTraits = '/profile/edit/traits';
  static const String profileEditWork = '/profile/edit/work';
  static const String profileEditMusicians = '/profile/edit/musicians';
  static const String profileEditMovies = '/profile/edit/movies';
  static const String profileEditDishes = '/profile/edit/dishes';
  static const String profileEditSocials = '/profile/edit/socials';
}
