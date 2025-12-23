import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/countdown_unit.dart';
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ROAD TO DOOMSDAY',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'DECEMBER 18, 2026',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                BlocBuilder<CountdownBloc, CountdownState>(
                  builder: (context, state) {
                    return switch (state) {
                      CountdownInitial() => const CircularProgressIndicator(),
                      CountdownComplete() => Text(
                          'DOOMSDAY IS HERE',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      CountdownRunning(:final days, :final hours, :final minutes, :final seconds) =>
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CountdownUnit(
                                value: days.toString().padLeft(3, '0'),
                                label: 'Days',
                              ),
                              const SizedBox(width: 8),
                              CountdownUnit(
                                value: hours.toString().padLeft(2, '0'),
                                label: 'Hrs',
                              ),
                              const SizedBox(width: 8),
                              CountdownUnit(
                                value: minutes.toString().padLeft(2, '0'),
                                label: 'Min',
                              ),
                              const SizedBox(width: 8),
                              CountdownUnit(
                                value: seconds.toString().padLeft(2, '0'),
                                label: 'Sec',
                              ),
                            ],
                          ),
                        ),
                    };
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
