import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/solver.dart';
import 'logger_service.dart';

class SolverService {
  // TODO: Replace with your actual backend URL
  static const String baseUrl = 'http://10.0.2.2:3000'; // For local testing

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
        LoggerService().logError(
          'Failed to load solvers: ${response.statusCode}', '');
        return [];
      }
    } on SocketException catch (e, stackTrace) {
      // No internet connection - warn but don't crash
      LoggerService().logError(
        'No internet connection',
        e,
        stackTrace,
      );
      return [];
    } on TimeoutException catch (e, stackTrace) {
      // Request timeout - warn but don't crash
      LoggerService().logError(
        'Request timeout',
        e,
        stackTrace,
      );
      return [];
    } catch (e, stackTrace) {
      // Other errors - warn but don't crash
      LoggerService().logError(
        'Failed to fetch solvers',
        e,
        stackTrace,
      );
      return [];
    }
  }
}
