import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/solvers_leaderboard_screen.dart';
import 'package:nanoplastics_app/services/service_locator.dart';
import 'package:nanoplastics_app/models/solver.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/fake_api_service.dart';

void main() {
  group('Leaderboard — top-10 loading', () {
    late FakeApiService fakeApi;

    setUp(() async {
      // Provide email + displayName so _userHasEmailAndBio is true and the
      // leaderboard FutureBuilder actually renders (not the restricted-access view).
      await setupServiceLocator({
        'display_name': 'Test User',
        'email': 'test@example.com',
        'profile_registered': true,
      });
      fakeApi = FakeApiService();
      ServiceLocator().overrideApiServiceForTesting(fakeApi);
    });

    testWidgets('shows 10 ranked solvers returned by API', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const SolversLeaderboardScreen()),
      );
      await tester.pumpAndSettle();

      // Each solver card should be rendered — rank is rendered as '#N'
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('Solver 1'), findsOneWidget);
      expect(find.text('Solver 10'), findsOneWidget);
    });

    testWidgets('shows empty / error state when API returns no solvers',
        (tester) async {
      fakeApi.solvers = [];

      await tester.pumpWidget(
        buildTestableWidget(const SolversLeaderboardScreen()),
      );
      await tester.pumpAndSettle();

      // No solver names should be present
      expect(find.text('Solver 1'), findsNothing);
    });

    testWidgets('recovers gracefully when API throws', (tester) async {
      fakeApi.solversError = Exception('network error');

      await tester.pumpWidget(
        buildTestableWidget(const SolversLeaderboardScreen()),
      );
      await tester.pumpAndSettle();

      // Screen must not crash — some error/empty UI should be visible
      expect(find.byType(SolversLeaderboardScreen), findsOneWidget);
    });

    testWidgets('registered solver name is shown unmasked', (tester) async {
      fakeApi.solvers = [
        const Solver(
          rank: 1,
          name: 'Alice Researcher',
          solutionsCount: 42,
          totalScore: 0,
          rating: 4.9,
          specialty: 'Marine Biology',
          isRegistered: true,
          hasAbstract: false,
        ),
      ];

      await tester.pumpWidget(
        buildTestableWidget(const SolversLeaderboardScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice Researcher'), findsOneWidget);
    });
  });
}
