import 'package:flutter/material.dart';

import '../models/launch_paper.dart';
import '../screens/paper_loader_screen.dart';
import 'pending_paper_open.dart';

/// Where a notification tap goes.
///
/// Cold launch reads the tap before `runApp`, so `nav` is null and the tap is
/// held until the first frame. A tap while the app is already running has a
/// navigator and goes straight through.
void routePaperOpen(LaunchPaper paper, NavigatorState? nav) {
  if (nav == null) {
    PendingPaperOpen.instance.stash(paper);
    return;
  }
  nav.push(MaterialPageRoute(
    builder: (_) => PaperLoaderScreen(
      paperId: paper.id,
      previewTitle: paper.title,
      previewPerex: paper.perex,
    ),
  ));
}
