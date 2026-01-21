import 'package:flutter/material.dart';

@immutable
class NesuiTheme extends ThemeExtension<NesuiTheme> {
  final Color brand;
  final Color onBrand;
  final Color border;
  final double radius;

  const NesuiTheme({
    required this.brand,
    required this.onBrand,
    required this.border,
    required this.radius,
  });

  factory NesuiTheme.defaults(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return NesuiTheme(
      brand: const Color(0xFF2563EB),
      onBrand: Colors.white,
      border: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
      radius: 12,
    );
  }

  @override
  NesuiTheme copyWith({
    Color? brand,
    Color? onBrand,
    Color? border,
    double? radius,
  }) {
    return NesuiTheme(
      brand: brand ?? this.brand,
      onBrand: onBrand ?? this.onBrand,
      border: border ?? this.border,
      radius: radius ?? this.radius,
    );
  }

  @override
  NesuiTheme lerp(ThemeExtension<NesuiTheme>? other, double t) {
    if (other is! NesuiTheme) return this;
    return NesuiTheme(
      brand: Color.lerp(brand, other.brand, t) ?? brand,
      onBrand: Color.lerp(onBrand, other.onBrand, t) ?? onBrand,
      border: Color.lerp(border, other.border, t) ?? border,
      radius: radius + (other.radius - radius) * t,
    );
  }
}

extension NesuiThemeX on BuildContext {
  NesuiTheme get nesui {
    final theme = Theme.of(this);
    return theme.extension<NesuiTheme>() ??
        NesuiTheme.defaults(theme.brightness);
  }
}
