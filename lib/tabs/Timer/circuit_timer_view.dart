import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:athlynew/colors.dart';

class CircuitTimerView extends StatefulWidget {
  const CircuitTimerView({super.key});

  @override
  State<CircuitTimerView> createState() => _CircuitTimerViewState();
}

enum CircuitPhase { work, rest, done }

class _CircuitTimerViewState extends State<CircuitTimerView> with SingleTickerProviderStateMixin {
  // ---------- Defaults (common) ----------
  Duration work = const Duration(seconds: 30);
  Duration rest = const Duration(seconds: 15); // rest between exercises
  int rounds = 3;
  int exercisesCount = 6;
  // --------------------------------------

  Timer? _timer;
  bool _isRunning = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  CircuitPhase _phase = CircuitPhase.work;

  int _round = 1;        // 1..rounds
  int _exercise = 1;     // 1..exercisesCount
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = work;
    
    // Setup scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  // ---------- Haptic Feedback ----------
  void _triggerHaptic() {
    HapticFeedback.mediumImpact();
  }

  void _triggerSuccessHaptic() {
    HapticFeedback.heavyImpact();
  }

  void _triggerPhaseChangeHaptic() {
    HapticFeedback.heavyImpact();
  }

  // ---------------- Timer Logic ----------------
  void _start() {
    if (_isRunning) return;
    if (_phase == CircuitPhase.done) _resetAll();

    _isRunning = true;
    _timer?.cancel();
    _triggerHaptic();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _nextStep();
        }
      });
    });

    setState(() {});
  }

  void _pause() {
    _timer?.cancel();
    _isRunning = false;
    _triggerHaptic();
    setState(() {});
  }

  void _togglePlay() => _isRunning ? _pause() : _start();

  void _resetAll() {
    _timer?.cancel();
    _isRunning = false;
    _phase = CircuitPhase.work;
    _round = 1;
    _exercise = 1;
    _remaining = work;
    _triggerHaptic();
    setState(() {});
  }

  void _skip() {
    if (_phase == CircuitPhase.done) return;
    _triggerHaptic();
    setState(() => _nextStep());
  }

  void _nextStep() {
    _triggerPhaseChangeHaptic();
    
    // End conditions:
    final isLastExercise = _exercise >= exercisesCount;
    final isLastRound = _round >= rounds;

    if (_phase == CircuitPhase.work) {
      // After WORK -> REST (if rest > 0) else jump
      if (rest.inSeconds > 0) {
        _phase = CircuitPhase.rest;
        _remaining = rest;
      } else {
        _advanceAfterRest(isLastExercise, isLastRound);
      }
      return;
    }

    if (_phase == CircuitPhase.rest) {
      _advanceAfterRest(isLastExercise, isLastRound);
      return;
    }
  }

  void _advanceAfterRest(bool isLastExercise, bool isLastRound) {
    if (!isLastExercise) {
      // Next exercise in same round
      _exercise++;
      _phase = CircuitPhase.work;
      _remaining = work;
      return;
    }

    // Finished exercises for this round
    if (!isLastRound) {
      _round++;
      _exercise = 1;
      _phase = CircuitPhase.work;
      _remaining = work;
      return;
    }

    // Finished everything
    _phase = CircuitPhase.done;
    _remaining = Duration.zero;
    _pause();
    _triggerSuccessHaptic();
  }

  // ---------------- Formatting ----------------
  String _format(Duration d) {
    final total = d.inSeconds;
    final m = total ~/ 60;
    final s = total % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String _phaseLabel() {
    switch (_phase) {
      case CircuitPhase.work:
        return "WORK";
      case CircuitPhase.rest:
        return "REST";
      case CircuitPhase.done:
        return "COMPLETE";
    }
  }

  String _currentTitle() {
    if (_phase == CircuitPhase.done) return "Finished";
    return "Exercise $_exercise";
  }

  Color _phaseColor() {
    switch (_phase) {
      case CircuitPhase.work:
        return AppColors.primary;
      case CircuitPhase.rest:
        return AppColors.accentBlue;
      case CircuitPhase.done:
        return Colors.green;
    }
  }

  double _progress() {
    final current = _phase == CircuitPhase.work ? work : rest;
    if (current.inSeconds == 0) return 1.0;
    final elapsed = current.inSeconds - _remaining.inSeconds;
    return (elapsed / current.inSeconds).clamp(0.0, 1.0);
  }

  // ---------------- Setup ----------------
  Future<void> _editSettings() async {
    if (_isRunning) _pause();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Duration localWork = work;
        Duration localRest = rest;
        int localRounds = rounds;
        int localExercises = exercisesCount;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Circuit Setup',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _TimePickerRow(
                      label: 'Work',
                      duration: localWork,
                      onChanged: (v) => setModalState(() => localWork = v),
                    ),
                    _TimePickerRow(
                      label: 'Rest',
                      duration: localRest,
                      onChanged: (v) => setModalState(() => localRest = v),
                    ),
                    const Divider(height: 32),
                    _CounterRow(
                      label: 'Rounds',
                      value: localRounds,
                      min: 1,
                      max: 30,
                      onChanged: (v) => setModalState(() => localRounds = v),
                    ),
                    _CounterRow(
                      label: 'Exercises',
                      value: localExercises,
                      min: 1,
                      max: 30,
                      onChanged: (v) => setModalState(() => localExercises = v),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            work = localWork;
                            rest = localRest;
                            rounds = localRounds;
                            exercisesCount = localExercises;
                          });
                          Navigator.of(ctx).pop();
                          _resetAll();
                        },
                        child: const Text(
                          'Apply Settings',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFDF5),
            AppColors.background,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Main card
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
                        // Mode switch
                        _ModeSwitch(
                          onSetupTap: _editSettings,
                        ),
                        const SizedBox(height: 12),

                        // Exercise title
                        Text(
                          _currentTitle(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // Timer circle with scale animation
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isRunning ? _scaleAnimation.value : 1.0,
                              child: child,
                            );
                          },
                          child: _TimerCircle(
                            timeText: _format(_remaining),
                            phaseLabel: _phaseLabel(),
                            progress: _progress(),
                            color: _phaseColor(),
                            round: _round,
                            totalRounds: rounds,
                            exercise: _exercise,
                            totalExercises: exercisesCount,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phase info
                        Text(
                          'Work ${_format(work)} • Rest ${_format(rest)} • Exercises $exercisesCount',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textDark.withOpacity(0.75),
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bottom buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset
                  Container(
                    width: 60,
                    height: 60,
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
                      onPressed: _resetAll,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Play/Pause
                  Container(
                    width: 70,
                    height: 70,
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
                      onPressed: _togglePlay,
                      icon: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Skip
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentBlue,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _skip,
                      icon: const Icon(
                        Icons.skip_next_rounded,
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

// ===== Mode Switch =====
class _ModeSwitch extends StatelessWidget {
  final VoidCallback onSetupTap;

  const _ModeSwitch({required this.onSetupTap});

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
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  'CIRCUIT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onSetupTap,
                child: Center(
                  child: Text(
                    'SETUP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.textDark.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Timer Circle with Hero Typography & Thin Progress =====
class _TimerCircle extends StatelessWidget {
  final String timeText;
  final String phaseLabel;
  final double progress;
  final Color color;
  final int round;
  final int totalRounds;
  final int exercise;
  final int totalExercises;

  const _TimerCircle({
    required this.timeText,
    required this.phaseLabel,
    required this.progress,
    required this.color,
    required this.round,
    required this.totalRounds,
    required this.exercise,
    required this.totalExercises,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 6, // Thin progress
              valueColor: AlwaysStoppedAnimation(
                color.withOpacity(0.2),
              ),
            ),
          ),
          // Foreground progress
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6, // Thin progress
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation(color),
              backgroundColor: Colors.transparent,
            ),
          ),
          // Hero typography
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeText,
                style: const TextStyle(
                  fontSize: 56, // Hero size
                  fontWeight: FontWeight.w800, // Extra bold
                  color: AppColors.textDark,
                  letterSpacing: -1,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                phaseLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Round $round / $totalRounds • Exercise $exercise / $totalExercises',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== Helper Widgets for Setup Sheet =====
class _TimePickerRow extends StatelessWidget {
  final String label;
  final Duration duration;
  final ValueChanged<Duration> onChanged;

  const _TimePickerRow({
    required this.label,
    required this.duration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              await showCupertinoModalPopup(
                context: context,
                builder: (ctx) {
                  int tempSeconds = duration.inSeconds;
                  return Container(
                    height: 250,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                            CupertinoButton(
                              child: const Text('Done'),
                              onPressed: () {
                                onChanged(Duration(seconds: tempSeconds));
                                Navigator.pop(ctx);
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: CupertinoTimerPicker(
                            mode: CupertinoTimerPickerMode.ms,
                            initialTimerDuration: duration,
                            onTimerDurationChanged: (d) {
                              tempSeconds = d.inSeconds;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(duration.inSeconds ~/ 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _CounterRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}