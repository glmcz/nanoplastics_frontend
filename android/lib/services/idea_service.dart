import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'logger_service.dart';
import 'settings_manager.dart';

class IdeaService {
  // TODO: Replace with your actual backend URL
  static const String baseUrl = 'http://10.0.2.2:3000'; // For Android emulator
  // For iOS simulator, use: 'http://localhost:3000'
  // For physical device, use your computer's IP: 'http://192.168.x.x:3000'

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

  /// Submit an idea to the backend
  static Future<Map<String, dynamic>> submitIdea({
    required String description,
    String? category,
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
      
      LoggerService().logUserAction(
        'submitting_idea_to_backend',
        params: {
          'url': uri.toString(),
          'category': category ?? 'none',
          'description_length': description.length,
        },
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout after 30 seconds');
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
      } else {
        LoggerService().logError(
          'idea_submission_failed',
          'HTTP ${response.statusCode}: ${response.body}',
        );
        return {
          'success': false,
          'message': 'Failed to submit idea: HTTP ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e, stackTrace) {
      LoggerService().logError(
        'idea_submission_exception',
        e,
        stackTrace,
      );
      return {
        'success': false,
        'message': 'Error submitting idea: ${e.toString()}',
        'error': e.toString(),
      };
    }
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
}
