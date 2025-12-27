import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HapticService {
  static void lightTap() {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('HapticService.lightTap failed: $e');
    }
  }

  static void mediumTap() {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('HapticService.mediumTap failed: $e');
    }
  }

  static void heavyTap() {
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('HapticService.heavyTap failed: $e');
    }
  }

  static void success() {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('HapticService.success failed: $e');
    }
  }

  static void missionComplete() {
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('HapticService.missionComplete failed: $e');
    }
  }

  static void selection() {
    try {
      HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('HapticService.selection failed: $e');
    }
  }

  static void rankUp() {
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('HapticService.rankUp failed: $e');
    }
  }
}
