import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:athlynew/colors.dart';

// ===== Interval Timer Screen (Warm-up -> Work/Rest x Rounds -> Cool-down) =====
class IntervalTimerView extends StatefulWidget {
  const IntervalTimerView({super.key});

  @override
  State<IntervalTimerView> createState() => _IntervalTimerViewState();
}

enum Phase { warmup, work, rest, cooldown, done }

class _IntervalTimerViewState extends State<IntervalTimerView> with SingleTickerProviderStateMixin {
  // ---------- Defaults (common) ----------
  Duration warmup = const Duration(seconds: 10);
  Duration work = const Duration(seconds: 30);
  Duration rest = const Duration(seconds: 15);
  Duration cooldown = const Duration(seconds: 10);
  int rounds = 8;
  // --------------------------------------

  Timer? _timer;
  bool _isRunning = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  Phase _phase = Phase.warmup;
  int _round = 1;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = warmup;
    
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
    if (_phase == Phase.done) _resetAll();

    _isRunning = true;
    _timer?.cancel();
    _triggerHaptic();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _nextPhase();
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
    _phase = Phase.warmup;
    _round = 1;
    _remaining = warmup;
    _triggerHaptic();
    setState(() {});
  }

  void _skip() {
    if (_phase == Phase.done) return;
    _triggerHaptic();
    setState(() => _nextPhase());
  }

  Duration _phaseDuration(Phase p) {
    switch (p) {
      case Phase.warmup:
        return warmup;
      case Phase.work:
        return work;
      case Phase.rest:
        return rest;
      case Phase.cooldown:
        return cooldown;
      case Phase.done:
        return Duration.zero;
    }
  }

  void _nextPhase() {
    _triggerPhaseChangeHaptic();
    
    switch (_phase) {
      case Phase.warmup:
        _phase = Phase.work;
        _remaining = work;
        break;

      case Phase.work:
        if (_round < rounds) {
          _phase = Phase.rest;
          _remaining = rest;
        } else {
          _phase = Phase.cooldown;
          _remaining = cooldown;
        }
        break;

      case Phase.rest:
        _round++;
        _phase = Phase.work;
        _remaining = work;
        break;

      case Phase.cooldown:
        _phase = Phase.done;
        _remaining = Duration.zero;
        _pause();
        _triggerSuccessHaptic();
        break;

      case Phase.done:
        break;
    }
  }

  String _format(Duration d) {
    final total = d.inSeconds;
    final m = total ~/ 60;
    final s = total % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String _phaseLabel() {
    switch (_phase) {
      case Phase.warmup:
        return "WARM UP";
      case Phase.work:
        return "WORK";
      case Phase.rest:
        return "REST";
      case Phase.cooldown:
        return "COOL DOWN";
      case Phase.done:
        return "COMPLETE";
    }
  }

  Color _phaseColor() {
    switch (_phase) {
      case Phase.warmup:
        return AppColors.secondary;
      case Phase.work:
        return AppColors.primary;
      case Phase.rest:
        return AppColors.accentBlue;
      case Phase.cooldown:
        return AppColors.secondary;
      case Phase.done:
        return Colors.green;
    }
  }

  double _progress() {
    final current = _phaseDuration(_phase);
    if (current.inSeconds == 0) return 1.0;
    final elapsed = current.inSeconds - _remaining.inSeconds;
    return (elapsed / current.inSeconds).clamp(0.0, 1.0);
  }

  // ---------------- Setup Sheet ----------------
  Future<void> _showSetup() async {
    if (_isRunning) _pause();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Duration localWarmup = warmup;
        Duration localWork = work;
        Duration localRest = rest;
        Duration localCooldown = cooldown;
        int localRounds = rounds;

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
                      'Interval Setup',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _TimePickerRow(
                      label: 'Warm-up',
                      duration: localWarmup,
                      onChanged: (v) => setModalState(() => localWarmup = v),
                    ),
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
                    _TimePickerRow(
                      label: 'Cool-down',
                      duration: localCooldown,
                      onChanged: (v) => setModalState(() => localCooldown = v),
                    ),
                    const Divider(height: 32),
                    _RoundsPicker(
                      rounds: localRounds,
                      onChanged: (v) => setModalState(() => localRounds = v),
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
                            warmup = localWarmup;
                            work = localWork;
                            rest = localRest;
                            cooldown = localCooldown;
                            rounds = localRounds;
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
                          onSetupTap: _showSetup,
                        ),
                        const SizedBox(height: 24),

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
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phase info
                        Text(
                          'Work ${_format(work)} • Rest ${_format(rest)} • Rounds $rounds',
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
                  'INTERVAL',
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

  const _TimerCircle({
    required this.timeText,
    required this.phaseLabel,
    required this.progress,
    required this.color,
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
              Text(
                _round > 0 ? 'Round: $_round' : '',
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

  int get _round {
    // This would need to be passed from parent in real implementation
    return 0;
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

class _RoundsPicker extends StatelessWidget {
  final int rounds;
  final ValueChanged<int> onChanged;

  const _RoundsPicker({
    required this.rounds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Rounds',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: rounds > 1 ? () => onChanged(rounds - 1) : null,
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
                rounds.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
            IconButton(
              onPressed: rounds < 20 ? () => onChanged(rounds + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}