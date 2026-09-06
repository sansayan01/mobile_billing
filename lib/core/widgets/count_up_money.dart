import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Premium continuous count-up money text — animates smoothly from [previousValue] → [value]
/// with ease-out cubic curve. Currency formatting stays stable and tabular.
///
/// When [value] changes (e.g., switching from Today to 7D), the counter rolls
/// continuously from the old amount to the new amount like a mechanical odometer.
class CountUpMoney extends StatefulWidget {
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
  State<CountUpMoney> createState() => _CountUpMoneyState();
}

class _CountUpMoneyState extends State<CountUpMoney> {
  double _prevValue = 0.0;

  @override
  void didUpdateWidget(CountUpMoney oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _prevValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(
      symbol: widget.symbol,
      decimalDigits: widget.decimalDigits,
      locale: 'en_IN',
    );
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.value),
      tween: Tween(
        begin: reduceMotion ? widget.value : _prevValue,
        end: widget.value,
      ),
      duration: reduceMotion ? Duration.zero : widget.duration,
      curve: widget.curve,
      builder: (context, v, _) => Text(
        format.format(v),
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Continuous non-currency count-up (e.g. bill counts, stock quantities).
class CountUpText extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText> {
  int _prevValue = 0;

  @override
  void didUpdateWidget(CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _prevValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.value),
      tween: Tween(
        begin: reduceMotion ? widget.value.toDouble() : _prevValue.toDouble(),
        end: widget.value.toDouble(),
      ),
      duration: reduceMotion ? Duration.zero : widget.duration,
      curve: widget.curve,
      builder: (context, v, _) => Text(
        v.round().toString(),
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
