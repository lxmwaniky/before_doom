import 'package:flutter/foundation.dart';

@immutable
sealed class CountdownEvent {
  const CountdownEvent();
}

class CountdownStarted extends CountdownEvent {
  const CountdownStarted();
}

class CountdownTicked extends CountdownEvent {
  const CountdownTicked();
}

class CountdownStopped extends CountdownEvent {
  const CountdownStopped();
}
