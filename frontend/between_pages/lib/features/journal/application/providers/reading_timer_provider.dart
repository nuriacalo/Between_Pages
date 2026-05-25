import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReadingItemType { book, manga, fanfic }

class ReadingTimerState {
  final int elapsedSeconds;
  final bool isRunning;
  final int? currentItemId;
  final ReadingItemType? itemType;

  const ReadingTimerState({
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.currentItemId,
    this.itemType,
  });

  ReadingTimerState copyWith({
    int? elapsedSeconds,
    bool? isRunning,
    int? currentItemId,
    ReadingItemType? itemType,
  }) {
    return ReadingTimerState(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      currentItemId: currentItemId ?? this.currentItemId,
      itemType: itemType ?? this.itemType,
    );
  }
}

class ReadingTimerNotifier extends StateNotifier<ReadingTimerState> {
  Timer? _timer;

  ReadingTimerNotifier() : super(const ReadingTimerState());

  void start(int itemId, ReadingItemType type) {
    if (state.isRunning && state.currentItemId == itemId) return;

    // Si inicia otro libro, reiniciamos el tiempo. Si es el mismo, lo resumimos.
    int initialSeconds = (state.currentItemId == itemId) ? state.elapsedSeconds : 0;

    state = state.copyWith(isRunning: true, currentItemId: itemId, itemType: type, elapsedSeconds: initialSeconds);
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    state = const ReadingTimerState();
  }

  void addSeconds(int secondsToAdd) {
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + secondsToAdd);
  }
}

final readingTimerProvider = StateNotifierProvider<ReadingTimerNotifier, ReadingTimerState>((ref) {
  return ReadingTimerNotifier();
});