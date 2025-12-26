import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

class TimerWidget extends StatefulWidget {
  final int durationMinutes;
  final VoidCallback onComplete;

  const TimerWidget({
    Key? key,
    required this.durationMinutes,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.durationMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        widget.onComplete();
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_totalSeconds - _remainingSeconds) / _totalSeconds;
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular progress
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: progress,
              isDark: isDark,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: AppTextStyles.h1(
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                    ).copyWith(fontSize: 48),
                  ),
                  Text(
                    'Minutes left',
                    style: AppTextStyles.body(
                      color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Pause/Resume button
        IconButton(
          onPressed: _togglePause,
          icon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              color: AppColors.goldPrimary,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _CircularProgressPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = (isDark ? AppColors.lavender : AppColors.lavenderDark).withOpacity(0.2)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 4, backgroundPaint);

    // Progress circle
    final progressPaint = Paint()
      ..color = isDark ? AppColors.goldPrimary : AppColors.goldPrimaryLight
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = (isDark ? AppColors.goldPrimary : AppColors.goldPrimaryLight).withOpacity(0.3)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}