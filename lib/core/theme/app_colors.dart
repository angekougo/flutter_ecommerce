import 'package:flutter/material.dart';

/// Palette Shoply (voir design system).
abstract final class AppColors {
  static const primary = Color(0xFF6E54FD);
  static const accent = Color(0xFFCF3BA7);

  static const background = Color(0xFFF8F9FB);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF171717);
  static const textSecondary = Color(0xFF737373);
  static const textMuted = Color(0xFFA1A1AA);
  static const border = Color(0xFFE5E7EB);

  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFF59E0B);
  static const star = Color(0xFFF59E0B);

  // Mode sombre
  static const darkBackground = Color(0xFF121218);
  static const darkSurface = Color(0xFF1C1C24);
  static const darkBorder = Color(0xFF2E2E38);
}

/// Espacements et rayons repris de la maquette.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

abstract final class AppRadius {
  static const small = 10.0;
  static const medium = 16.0;
  static const large = 24.0;
}
