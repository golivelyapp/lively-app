/// The new streamlined onboarding: 6 content steps + intro + review.
/// Height, Traits, Musicians, Movies, Dishes, Socials now live inside the
/// Profile tab as optional enhancements — not part of the wizard.
enum OnboardingStep {
  intro,
  basics,
  profilePicture,
  activities,
  bio,
  selfieVerification;

  static const List<OnboardingStep> progressTracked = <OnboardingStep>[
    basics,
    profilePicture,
    activities,
    bio,
    selfieVerification,
  ];

  int get progressIndex => progressTracked.indexOf(this);

  double get progressRatio =>
      progressIndex < 0 ? 0 : (progressIndex + 1) / progressTracked.length;
}
