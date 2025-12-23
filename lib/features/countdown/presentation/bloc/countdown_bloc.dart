import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import 'countdown_event.dart';
import 'countdown_state.dart';

class CountdownBloc extends Bloc<CountdownEvent, CountdownState> {
  Timer? _timer;

  CountdownBloc() : super(const CountdownInitial()) {
    on<CountdownStarted>(_onStarted);
    on<CountdownTicked>(_onTicked);
    on<CountdownStopped>(_onStopped);
  }

  void _onStarted(CountdownStarted event, Emitter<CountdownState> emit) {
    _timer?.cancel();
    _emitCurrentTime(emit);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const CountdownTicked());
    });
  }

  void _onTicked(CountdownTicked event, Emitter<CountdownState> emit) {
    _emitCurrentTime(emit);
  }

  void _onStopped(CountdownStopped event, Emitter<CountdownState> emit) {
    _timer?.cancel();
    _timer = null;
  }

  void _emitCurrentTime(Emitter<CountdownState> emit) {
    final now = DateTime.now().toUtc();
    final difference = AppConstants.doomsdayDate.difference(now);

    if (difference.isNegative) {
      emit(const CountdownComplete());
      _timer?.cancel();
    } else {
      emit(CountdownRunning.fromDuration(difference));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
