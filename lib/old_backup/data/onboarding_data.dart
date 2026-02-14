import '../models/onboarding_page.dart';

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      titleKey: 'onboarding_welcome_title',
      descriptionKey: 'onboarding_welcome_desc',
      icon: '🧬',
      gradient1: '#3B82F6',
      gradient2: '#8B5CF6',
    ),
    OnboardingPage(
      titleKey: 'onboarding_problem_title',
      descriptionKey: 'onboarding_problem_desc',
      icon: '⚠️',
      gradient1: '#EF4444',
      gradient2: '#F97316',
    ),
    OnboardingPage(
      titleKey: 'onboarding_solution_title',
      descriptionKey: 'onboarding_solution_desc',
      icon: '💡',
      gradient1: '#10B981',
      gradient2: '#06B6D4',
    ),
    OnboardingPage(
      titleKey: 'onboarding_paths_title',
      descriptionKey: 'onboarding_paths_desc',
      icon: '🌍',
      gradient1: '#A855F7',
      gradient2: '#3B82F6',
    ),
  ];
}
