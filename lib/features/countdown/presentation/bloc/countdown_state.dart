import 'package:flutter/foundation.dart';

@immutable
sealed class CountdownState {
  const CountdownState();
}

class CountdownInitial extends CountdownState {
  const CountdownInitial();
}

class CountdownRunning extends CountdownState {
  final Duration timeLeft;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  const CountdownRunning({
    required this.timeLeft,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  factory CountdownRunning.fromDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return CountdownRunning(
      timeLeft: duration,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }
}

class CountdownComplete extends CountdownState {
  const CountdownComplete();
}
