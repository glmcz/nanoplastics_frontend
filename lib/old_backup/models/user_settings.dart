
// simple Settings for new screen after a click
// it only hold data so can be final as well
class UserSettings {
  final String fullName;
  final String email;
  final String? avatarPath;
  final bool notificationsEnabled;
  final String language;

  UserSettings({
    required this.fullName,
    required this.email,
    this.avatarPath,
    required this.notificationsEnabled,
    required this.language,
  });

  UserSettings copyWith({
    String? fullName,
    String? email,
    String? avatarPath,
    bool? notificationsEnabled,
    String? language,
  }) {
    return UserSettings(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }
}