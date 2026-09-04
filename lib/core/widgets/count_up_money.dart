import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Premium count-up money text — animates 0 → [value] with ease-out and
/// an optional fade-in. Currency formatting stays stable (tabular feel)
/// because the formatter is fixed for the whole animation.
///
/// Usage: `CountUpMoney(value: 12450.0, style: ...)` — re-animates only
/// when [value] changes (grouped by [ValueKey]).
class CountUpMoney extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final String symbol;
  final int decimalDigits;
  final Curve curve;

  const CountUpMoney({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.symbol = '₹',
    this.decimalDigits = 0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
      locale: 'en_IN',
    );
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: 0.0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, v, _) => Text(
        format.format(v),
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Non-currency count-up (e.g. bill counts, stock numbers).
class CountUpText extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: 0.0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, v, _) => Text(
        v.round().toString(),
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
