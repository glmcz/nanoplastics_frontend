import 'package:mocktail/mocktail.dart';
import 'package:nanoplastics_app/services/api_service.dart';
import 'package:nanoplastics_app/models/solver.dart';
import 'package:nanoplastics_app/models/idea_attachment.dart';

/// A test double for ApiService. Override only the methods your test needs.
/// Unoverridden methods throw `UnimplementedError` via Fake, revealing gaps.
class FakeApiService extends Fake implements ApiService {
  /// Top-solvers response. Defaults to 10 ranked solvers.
  List<Solver> solvers = List.generate(
    10,
    (i) => Solver(
      rank: i + 1,
      name: 'Solver ${i + 1}',
      solutionsCount: 10 - i,
      totalScore: 0,
      rating: 5.0 - i * 0.1,
      specialty: 'Biology',
      isRegistered: true,
      hasAbstract: false,
    ),
  );

  /// Controls whether [getTopSolvers] throws.
  Exception? solversError;

  /// Records calls to [submitIdea].
  final List<Map<String, dynamic>> submitCalls = [];

  /// Result returned by [submitIdea]. Defaults to success.
  Map<String, dynamic> submitResult = {'success': true, 'message': 'OK'};

  @override
  Future<List<Solver>> getTopSolvers() async {
    if (solversError != null) throw solversError!;
    return solvers;
  }

  @override
  Future<Map<String, dynamic>> submitIdea({
    required String description,
    String? category,
    List<IdeaAttachment>? attachments,
    String? email,
    String? turnstileToken,
  }) async {
    submitCalls.add({
      'description': description,
      'category': category,
      'attachments': attachments,
      'email': email,
      'turnstileToken': turnstileToken,
    });
    return submitResult;
  }

  @override
  String get baseUrl => 'https://test.example';

  @override
  Future<bool> healthCheck() async => true;
}
