import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// 56dp countdown ring with 5dp stroke.
/// Color phases: neutral >66%, amber 33-66%, red <33%.
/// Gray "reconnecting" state when socket is lost.
class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.isReconnecting = false,
    this.size = AppSizes.countdownRingSize,
    this.strokeWidth = AppSizes.countdownRingStroke,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final bool isReconnecting;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    if (isReconnecting) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: null,
                strokeWidth: strokeWidth,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            Icon(
              Icons.wifi_off,
              size: size * 0.35,
              color: Colors.grey.withOpacity(0.7),
            ),
          ],
        ),
      );
    }

    final fraction = totalSeconds > 0
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final ringColor = _ringColor(fraction);
    final textColor = _ringColor(fraction);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              color: ringColor.withOpacity(0.15),
            ),
          ),
          // Filled arc
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: strokeWidth,
              color: ringColor,
            ),
          ),
          // Countdown text
          Text(
            _formatTime(remainingSeconds),
            style: AppTextStyles.countdown.copyWith(
              color: textColor,
              fontSize: size * 0.28,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Color _ringColor(double fraction) {
    if (fraction > 0.66) return AppColors.primary; // neutral
    if (fraction > 0.33) return AppColors.queuePulse; // amber
    return AppColors.lateAlarm; // red
  }

  String _formatTime(int secs) {
    if (secs >= 60) {
      final m = secs ~/ 60;
      final s = secs % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    return '${secs}s';
  }
}
