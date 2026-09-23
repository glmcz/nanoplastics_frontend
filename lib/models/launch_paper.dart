/// A paper the user tapped in a notification, before the record is loaded.
///
/// Title and perex come from the push payload, so the screen draws real content
/// immediately instead of a spinner while the fetch is in flight.
class LaunchPaper {
  final String id;
  final String? title;
  final String? perex;

  const LaunchPaper(this.id, this.title, {this.perex});

  /// The `data` map of an FCM message. Returns null when there is no paper in it.
  static LaunchPaper? fromPushData(
    Map<String, dynamic> data, {
    String? notificationTitle,
  }) {
    final id = data['paper_id'] as String?;
    if (id == null || id.isEmpty) return null;
    // The data map's title is preferred: the notification block is not always
    // readable, and on a data-only message there is no notification at all.
    final title = (data['title'] as String?) ?? notificationTitle;
    return LaunchPaper(id, title, perex: data['perex'] as String?);
  }
}
