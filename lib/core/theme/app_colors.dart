// PlateRoute color tokens — dark is the shipping default.
import 'package:flutter/material.dart';

/// Brand color tokens mapped exactly to the design spec.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF60A5FA); // link variant in dark

  // Action
  static const actionAccept = Color(0xFF15803D); // light
  static const actionAcceptDark = Color(0xFF16A34A); // dark

  // Reject
  static const rejectSurface = Color(0xFFFEF2F2);
  static const rejectOutline = Color(0xFFB91C1C);

  // Queue / urgency pulse — reserved ONLY for actionable-now state
  static const queuePulse = Color(0xFFF59E0B); // light
  static const queuePulseDark = Color(0xFFFBBF24); // dark

  // Late / deadline
  static const lateAlarm = Color(0xFFDC2626);

  // Surfaces
  static const surfaceLight = Color(0xFFFFFFFF);
  static const canvasLight = Color(0xFFF1F5F9);
  static const surfaceDark = Color(0xFF0F172A);
  static const canvasDark = Color(0xFF101A2C);

  // Text
  static const textPrimaryLight = Color(0xFF0F172A);
  static const textSecondaryLight = Color(0xFF334155);
  static const textPrimaryDark = Color(0xFFF1F5FB);
  static const textSecondaryDark = Color(0xFF94A3B8);

  // Status grammar
  static const success = Color(0xFF16A34A);
  static const info = Color(0xFF2563EB);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFDC2626);

  // Bucket borders
  static const borderActNow = Color(0xFFF59E0B); // amber
  static const borderInKitchen = Color(0xFF2563EB); // blue
  static const borderLate = Color(0xFFDC2626); // red 3dp

  // Misc
  static const divider = Color(0xFF1E293B);
  static const chipSelected = Color(0xFF1E40AF);
}
