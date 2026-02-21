import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/solver.dart';
import '../models/idea_attachment.dart';
import '../config/backend_config.dart';
import 'logger_service.dart';
import 'settings_manager.dart';

class ApiService {
  /// Get backend base URL from centralized config
  /// Can be overridden at build time using:
  ///   flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000
  /// Or via GitHub Actions secrets at build time
  static String get baseUrl => BackendConfig.getBaseUrl();

  /// Get or create user UUID for consistent identification across submissions
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('user_id', userId);
    }

    return userId;
  }

  /// Health check to verify backend connectivity
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      LoggerService().logUserAction(
        'backend_health_check_failed',
        params: {'error': e.toString()},
      );
      return false;
    }
  }

  /// Submit an idea to the backend
  static Future<Map<String, dynamic>> submitIdea({
    required String description,
    String? category,
    List<IdeaAttachment>? attachments,
  }) async {
    try {
      final userId = await getUserId();

      final settings = SettingsManager();
      final userEmail = settings.email;
      final userNickName = settings.displayName;

      // Create multipart request
      final uri = Uri.parse('$baseUrl/api/ideas');
      final request = http.MultipartRequest('POST', uri);

      request.fields['user_id'] = userId;
      request.fields['description'] = description;

      if (category != null && category.isNotEmpty) {
        request.fields['category'] = category;
      }

      if (userNickName.isNotEmpty) {
        request.fields['nick_name'] = userNickName;
      }

      if (userEmail.isNotEmpty) {
        request.fields['email'] = userEmail;
      }

      // Attach files
      for (final att in attachments ?? []) {
        request.files.add(await http.MultipartFile.fromPath(
          'attachment',
          att.path,
          contentType: MediaType.parse(att.mimeType),
          filename: att.name,
        ));
      }

      LoggerService().logUserAction(
        'submitting_idea_to_backend',
        params: {
          'url': uri.toString(),
          'category': category ?? 'none',
          'description_length': description.length,
          'attachment_count': (attachments ?? []).length,
        },
      );

      if (description.length < 10) {
        return {
          'success': false,
          'message': 'The idea description should have at least 10 characters.',
        };
      }

      // Extended timeout to allow large file uploads (videos, audio)
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException('Request timeout after 120 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      LoggerService().logNetworkCall(
        '/api/ideas',
        method: 'POST',
        statusCode: response.statusCode,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        LoggerService().logUserAction(
          'idea_submitted_successfully',
          params: {
            'category': category ?? 'none',
            'description_length': description.length,
          },
        );
        return {
          'success': true,
          'message': 'Idea submitted successfully',
          'response_body': response.body,
        };
      } else if (response.statusCode == 502 || response.statusCode == 503) {
        LoggerService().logError(
          'idea_submission_backend_down',
          'Backend unreachable via proxy: ${response.statusCode}: ${response.body}',
        );
        return {
          'success': false,
          'type': 'connection',
          'message':
              'Server is temporarily unavailable. Please try again later.',
          'error': response.body,
        };
      } else {
        LoggerService().logError(
          'idea_submission_failed',
          'Remote server is not available. Getting: ${response.statusCode}: ${response.body}',
        );
        return {
          'success': false,
          'message': 'Failed to submit idea: HTTP ${response.statusCode}',
          'error': response.body,
        };
      }
    } on SocketException catch (e, stackTrace) {
      LoggerService().logError('idea_submission_no_connection', e, stackTrace);
      return {
        'success': false,
        'type': 'connection',
        'message': 'Server is unreachable. Check your internet connection.',
        'error': e.toString(),
      };
    } on TimeoutException catch (e, stackTrace) {
      LoggerService().logError('idea_submission_timeout', e, stackTrace);
      return {
        'success': false,
        'type': 'timeout',
        'message': 'Server is not responding. Please try again later.',
        'error': e.toString(),
      };
    } catch (e, stackTrace) {
      LoggerService().logError(
        'idea_submission_exception',
        e,
        stackTrace,
      );
      return {
        'success': false,
        'type': 'unknown',
        'message': 'Error submitting idea: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Fetch top solvers from backend API
  static Future<List<Solver>> getTopSolvers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/solvers'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final solvers = data['solvers'] as List<dynamic>;

        return solvers
            .map((solverData) => Solver(
                  rank: solverData['rank'] as int,
                  name: solverData['name'] as String,
                  solutionsCount: solverData['contributions'] as int,
                  rating: (solverData['rating'] as num).toDouble(),
                  specialty: solverData['specialty'] as String? ?? 'General',
                  isRegistered: solverData['is_registered'] as bool,
                ))
            .toList();
      } else {
        LoggerService()
            .logError('Failed to load solvers: ${response.statusCode}', '');
        return [];
      }
    } on SocketException catch (e, stackTrace) {
      LoggerService().logError('No internet connection', e, stackTrace);
      return [];
    } on TimeoutException catch (e, stackTrace) {
      LoggerService().logError('Request timeout', e, stackTrace);
      return [];
    } catch (e, stackTrace) {
      LoggerService().logError('Failed to fetch solvers', e, stackTrace);
      return [];
    }
  }
}
