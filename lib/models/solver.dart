import '../services/encryption_service.dart';

class Solver {
  final int rank;
  final String name;
  final int solutionsCount;
  final double rating;
  final String specialty;
  final bool isRegistered;

  const Solver({
    required this.rank,
    required this.name,
    required this.solutionsCount,
    required this.rating,
    required this.specialty,
    required this.isRegistered,
  });

  /// Get display name based on registration status
  /// Registered users see real names, unregistered see hashed IDs
  String getDisplayName() {
    if (isRegistered) {
      return name;
    }
    // For unregistered users, show hashed identifier
    return EncryptionService.generateHashedNickname(name);
  }

  /// Get masked name for display - shows asterisks for unregistered users
  String getMaskedName() {
    if (isRegistered) {
      return name;
    }
    // Show masked version for privacy
    if (name.length <= 3) {
      return '****';
    }
    final visibleLength = (name.length / 3).ceil();
    final visible = name.substring(0, visibleLength);
    final masked = '*' * (name.length - visibleLength);
    return visible + masked;
  }

  /// Get specialty display - shows actual specialty if registered, hidden if not
  String getSpecialty() {
    return isRegistered ? specialty : 'Unknown';
  }
}
