import 'package:flutter/material.dart';

enum StatusRank {
  recruit(0, 'Recruit', 'Just enlisted', Icons.person_outline),
  agent(10, 'Agent', 'Field operative', Icons.badge),
  avenger(25, 'Avenger', 'Earth\'s mightiest', Icons.shield),
  guardian(50, 'Guardian', 'Cosmic protector', Icons.rocket_launch),
  multiversalEntity(75, 'Multiversal Entity', 'Beyond reality', Icons.blur_on),
  timeKeeper(100, 'Time Keeper', 'Master of time', Icons.all_inclusive);

  final int minProgress;
  final String title;
  final String subtitle;
  final IconData icon;

  const StatusRank(this.minProgress, this.title, this.subtitle, this.icon);

  static StatusRank fromProgress(double progressPercentage) {
    if (progressPercentage >= 100) return StatusRank.timeKeeper;
    if (progressPercentage >= 75) return StatusRank.multiversalEntity;
    if (progressPercentage >= 50) return StatusRank.guardian;
    if (progressPercentage >= 25) return StatusRank.avenger;
    if (progressPercentage >= 10) return StatusRank.agent;
    return StatusRank.recruit;
  }

  StatusRank? get nextRank {
    final ranks = StatusRank.values;
    final currentIndex = ranks.indexOf(this);
    if (currentIndex < ranks.length - 1) {
      return ranks[currentIndex + 1];
    }
    return null;
  }

  double progressToNextRank(double currentProgress) {
    final next = nextRank;
    if (next == null) return 1.0;

    final rangeStart = minProgress.toDouble();
    final rangeEnd = next.minProgress.toDouble();
    final progressInRange = currentProgress - rangeStart;
    final rangeSize = rangeEnd - rangeStart;

    return (progressInRange / rangeSize).clamp(0.0, 1.0);
  }
}
