import 'package:flutter/scheduler.dart';

import '../events/events.dart';

class GxTicker {
  GxTicker();

  Ticker _ticker;
  EventSignal<double> _onFrame;
  EventSignal<double> get onFrame => _onFrame ??= EventSignal();

  VoidCallback _nextFrameCallback;

  void callNextFrame(VoidCallback callback) {
    _nextFrameCallback = callback;
  }

  void _createTicker() {
    if (_ticker != null) return;
    _ticker = Ticker(_onTick);
    _ticker.start();
    _ticker.muted = true;
  }

  bool get isTicking => _ticker?.isTicking ?? false;

  bool get isActive => _ticker?.isActive ?? false;

  void resume() {
    if (isTicking) return;
    _createTicker();
    _ticker?.muted = false;
  }

  void pause() {
    if (!isTicking) return;
    _ticker?.muted = true;
  }

  /// process timeframe in integer MS
  double _currentTime = 0;
  double _currentDeltaTime = 0;

  double frameRate = 60.0;

  /// enterframe ticker
  void _onTick(Duration elapsed) {
    var now = elapsed.inMilliseconds.toDouble() * .001;
    _currentDeltaTime = (now - _currentTime);
    _currentTime = now;

    /// avoid overloading frames (happens per scene).
//    _currentDeltaTime = _currentDeltaTime.clamp(1.0 / frameRate, 1.0);
    if (_nextFrameCallback != null) {
      var callback = _nextFrameCallback;
      _nextFrameCallback = null;
      callback?.call();
    }
    _onFrame?.dispatch(_currentDeltaTime);
//    advanceTime(_currentDeltaTime);
//    render();
  }

  void dispose() {
    _onFrame?.removeAll();
    _onFrame = null;

    _ticker?.stop(canceled: true);
    _ticker?.dispose();
    _ticker = null;
  }
}

Stopwatch _stopwatch;

void _initTimer() {
  if (_stopwatch != null) return;
  _stopwatch = Stopwatch();
  _stopwatch.start();
}

int getTimer() {
  if (_stopwatch == null) {
    _initTimer();
  }
  return _stopwatch.elapsedMilliseconds;
}
