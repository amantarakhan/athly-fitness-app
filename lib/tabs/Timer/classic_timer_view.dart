import 'dart:async';
import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';

class ClassicTimerView extends StatefulWidget {
  const ClassicTimerView({super.key});

  @override
  State<ClassicTimerView> createState() => _ClassicTimerViewState();
}

class _ClassicTimerViewState extends State<ClassicTimerView> {
  bool _isCountdown = true;
  bool _isRunning = false;
  Timer? _timer;

  // Countdown: default 5 minutes (300 seconds)
  static const int _defaultCountdownSeconds = 300;
  int _totalCountdownSeconds = _defaultCountdownSeconds;
  int _remainingSeconds = _defaultCountdownSeconds;

  // Stopwatch: count up
  int _elapsedSeconds = 0;
  static const int _stopwatchVisualMax = 600; // 10 minutes for progress ring

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------- Time helpers ----------

  String _formatSeconds(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _timeText {
    if (_isCountdown) {
      return _formatSeconds(_remainingSeconds);
    } else {
      return _formatSeconds(_elapsedSeconds);
    }
  }

  String get _baseCountdownText =>
      'Tap to set time (currently ${_formatSeconds(_totalCountdownSeconds)})';

  double get _progress {
    if (_isCountdown) {
      if (_totalCountdownSeconds == 0) return 0;
      final done =
          (_totalCountdownSeconds - _remainingSeconds) / _totalCountdownSeconds;
      return done.clamp(0.0, 1.0);
    } else {
      final p = _elapsedSeconds / _stopwatchVisualMax;
      return p.clamp(0.0, 1.0);
    }
  }

  // ---------- Timer control ----------

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isCountdown) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          t.cancel();
          setState(() => _isRunning = false);
          // Optional: show a SnackBar or sound here
        }
      } else {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
    setState(() => _isRunning = true);
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalCountdownSeconds;
      _elapsedSeconds = 0;
    });
  }

  void _switchMode(bool toCountdown) {
    _timer?.cancel();
    setState(() {
      _isCountdown = toCountdown;
      _isRunning = false;
      _remainingSeconds = _totalCountdownSeconds;
      _elapsedSeconds = 0;
    });
  }

  // ---------- Bottom sheet: pick countdown time ----------

  Future<void> _pickCountdownTime() async {
    if (!_isCountdown) return;
    if (_isRunning) _pauseTimer();

    int tempMinutes = _totalCountdownSeconds ~/ 60;
    if (tempMinutes <= 0) tempMinutes = 1;

    final selected = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        int localMinutes = tempMinutes;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Set countdown time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${localMinutes.toString().padLeft(2, '0')}:00',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: localMinutes.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '$localMinutes min',
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      setModalState(() {
                        localMinutes = v.round();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop(localMinutes);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Set timer',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _totalCountdownSeconds = selected * 60;
        _remainingSeconds = _totalCountdownSeconds;
        _isRunning = false;
      });
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFDF5), // very light cream
            AppColors.background,
          ],
        ),
      ),
      child: SafeArea(
        top: false, // AppBar already handles top inset
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ------------ Main Card ------------
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Stopwatch / Countdown switch
                        _ModeSwitch(
                          isCountdown: _isCountdown,
                          onChanged: (value) {
                            _switchMode(value);
                          },
                        ),
                        const SizedBox(height: 24),

                        // Circular timer
                        _TimerCircle(
                          timeText: _timeText,
                          progress: _progress,
                        ),

                        const SizedBox(height: 16),

                        // Tap text
                        GestureDetector(
                          onTap: () {
                            if (_isCountdown) {
                              _pickCountdownTime();
                            } else {
                              // you could start stopwatch on tap if you want later
                            }
                          },
                          child: Text(
                            _isCountdown
                                ? _baseCountdownText
                                : 'Tap to start stopwatch',
                            style: textTheme.bodyMedium?.copyWith(
                              color:
                                  AppColors.textDark.withOpacity(0.75),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Illustration area
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              'assets/images/timer.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------------ Bottom Buttons ------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _resetTimer,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  // Play (start / pause)
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (_isRunning) {
                          _pauseTimer();
                        } else {
                          _startTimer();
                        }
                      },
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Mode Switch (Stopwatch / Countdown) =====

class _ModeSwitch extends StatelessWidget {
  final bool isCountdown;
  final ValueChanged<bool> onChanged;

  const _ModeSwitch({
    required this.isCountdown,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EB),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: 'STOPWATCH',
              isActive: !isCountdown,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ModeChip(
              label: 'COUNTDOWN',
              isActive: isCountdown,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: isActive
                    ? Colors.white
                    : AppColors.textDark.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Circular Timer Ring =====

class _TimerCircle extends StatelessWidget {
  final String timeText;
  final double progress;

  const _TimerCircle({
    required this.timeText,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 190,
            height: 190,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 10,
              valueColor: AlwaysStoppedAnimation(
                AppColors.accentBlue.withOpacity(0.25),
              ),
            ),
          ),
          // Foreground progress
          SizedBox(
            width: 190,
            height: 190,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              backgroundColor: Colors.transparent,
            ),
          ),
          // Time text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeText,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'minutes',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
