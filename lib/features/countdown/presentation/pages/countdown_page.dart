import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/countdown_bloc.dart';
import '../bloc/countdown_event.dart';
import '../bloc/countdown_state.dart';

class CountdownPage extends StatelessWidget {
  const CountdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CountdownBloc()..add(const CountdownStarted()),
      child: const CountdownView(),
    );
  }
}

class CountdownView extends StatelessWidget {
  const CountdownView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface,
              theme.colorScheme.primary.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLogo(theme),
              const SizedBox(height: 32),
              _buildTitle(theme),
              const SizedBox(height: 48),
              BlocBuilder<CountdownBloc, CountdownState>(
                builder: (context, state) {
                  return switch (state) {
                    CountdownInitial() => const CircularProgressIndicator(),
                    CountdownComplete() => _buildDoomsdayArrived(theme),
                    CountdownRunning(
                      :final days,
                      :final hours,
                      :final minutes,
                      :final seconds
                    ) =>
                      _buildCountdown(theme, size, days, hours, minutes, seconds),
                  };
                },
              ),
              const Spacer(flex: 3),
              _buildFooter(theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Text(
          'AVENGERS',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w300,
            letterSpacing: 8,
          ),
        ),
        Text(
          'DOOMSDAY',
          style: theme.textTheme.displayMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.secondary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'DECEMBER 18, 2026',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.secondary,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdown(
    ThemeData theme,
    Size size,
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCountdownUnit(theme, days, 'DAYS', isLarge: true),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCountdownUnit(theme, hours, 'HRS'),
            _buildSeparator(theme),
            _buildCountdownUnit(theme, minutes, 'MIN'),
            _buildSeparator(theme),
            _buildCountdownUnit(theme, seconds, 'SEC'),
          ],
        ),
      ],
    );
  }

  Widget _buildCountdownUnit(ThemeData theme, int value, String label,
      {bool isLarge = false}) {
    return Column(
      children: [
        Text(
          isLarge
              ? value.toString()
              : value.toString().padLeft(2, '0'),
          style: isLarge
              ? theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 80,
                )
              : theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w300,
                ),
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        ':',
        style: theme.textTheme.headlineLarge?.copyWith(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildDoomsdayArrived(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.celebration,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'DOOMSDAY',
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        Text(
          'IS HERE',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w300,
            letterSpacing: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        Text(
          'THE ROAD TO DOOMSDAY',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your MCU Rewatch Journey',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}
