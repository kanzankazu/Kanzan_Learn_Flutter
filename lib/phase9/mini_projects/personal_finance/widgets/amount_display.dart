/// Reusable widget that formats and displays a monetary amount.
///
/// Always displays in Indonesian Rupiah (IDR) format: Rp1.250.000
/// Negative amounts are shown in red by default.
import 'package:flutter/material.dart';

class AmountDisplay extends StatelessWidget {
  /// The amount to display (in IDR).
  final double amount;

  /// Optional text style override. If null, uses the surrounding theme.
  final TextStyle? style;

  /// Whether to show negative amounts in red.
  final bool colorizeNegative;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.style,
    this.colorizeNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    final formatted = _format(amount.abs());
    final display = isNegative ? '-Rp$formatted' : 'Rp$formatted';

    TextStyle? effectiveStyle = style;
    if (colorizeNegative && isNegative) {
      effectiveStyle = (style ?? const TextStyle()).copyWith(color: Colors.red);
    }

    return Text(display, style: effectiveStyle);
  }

  /// Formats [value] as "1.250.000" (Indonesian thousands separator is '.').
  static String _format(double value) {
    final parts = value.toStringAsFixed(0).split('');
    final result = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) result.write('.');
      result.write(parts[i]);
    }
    return result.toString();
  }
}
