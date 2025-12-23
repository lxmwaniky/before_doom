import 'package:flutter/material.dart';

@immutable
class DoomColors extends ThemeExtension<DoomColors> {
  final Color doomGreen;
  final Color vibraniumSilver;
  final Color infinityPurple;

  const DoomColors({
    required this.doomGreen,
    required this.vibraniumSilver,
    required this.infinityPurple,
  });

  @override
  DoomColors copyWith({
    Color? doomGreen,
    Color? vibraniumSilver,
    Color? infinityPurple,
  }) {
    return DoomColors(
      doomGreen: doomGreen ?? this.doomGreen,
      vibraniumSilver: vibraniumSilver ?? this.vibraniumSilver,
      infinityPurple: infinityPurple ?? this.infinityPurple,
    );
  }

  @override
  DoomColors lerp(ThemeExtension<DoomColors>? other, double t) {
    if (other is! DoomColors) return this;
    return DoomColors(
      doomGreen: Color.lerp(doomGreen, other.doomGreen, t)!,
      vibraniumSilver: Color.lerp(vibraniumSilver, other.vibraniumSilver, t)!,
      infinityPurple: Color.lerp(infinityPurple, other.infinityPurple, t)!,
    );
  }
}
