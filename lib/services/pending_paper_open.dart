import '../models/launch_paper.dart';

/// A tap that arrived before the navigator existed.
///
/// On a cold launch the notification is read before `runApp`, so there is no
/// navigator to push onto yet. The previous code polled for one every 50ms for
/// up to two seconds; this holds the tap instead and the first frame consumes it.
class PendingPaperOpen {
  static final PendingPaperOpen instance = PendingPaperOpen._();
  PendingPaperOpen._();

  LaunchPaper? _pending;

  void stash(LaunchPaper paper) => _pending = paper;

  /// Returns the pending tap and clears it, so it can only open once.
  LaunchPaper? take() {
    final pending = _pending;
    _pending = null;
    return pending;
  }
}
