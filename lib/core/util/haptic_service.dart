import 'package:flutter/services.dart';

class HapticService {
  static void lightTap() {
    HapticFeedback.lightImpact();
  }

  static void mediumTap() {
    HapticFeedback.mediumImpact();
  }

  static void heavyTap() {
    HapticFeedback.heavyImpact();
  }

  static void success() {
    HapticFeedback.mediumImpact();
  }

  static void missionComplete() {
    HapticFeedback.heavyImpact();
  }

  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void rankUp() {
    HapticFeedback.heavyImpact();
  }
}
