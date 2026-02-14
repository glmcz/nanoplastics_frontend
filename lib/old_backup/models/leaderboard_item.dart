import 'package:flutter/material.dart';

class LeaderboardItem {
  final int rank;
  final String title;
  final String category;
  final Color categoryColor;
  final int votes;
  final int aiScore;

  const LeaderboardItem({
    required this.rank,
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.votes,
    required this.aiScore,
  });

  bool get isTopRank => rank <= 2;
}
