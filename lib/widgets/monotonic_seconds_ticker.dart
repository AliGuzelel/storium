import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';



class MonotonicSecondsTicker extends StatefulWidget {
  const MonotonicSecondsTicker({super.key, required this.builder});

  final Widget Function(BuildContext context, double seconds) builder;

  @override
  State<MonotonicSecondsTicker> createState() => _MonotonicSecondsTickerState();
}

class _MonotonicSecondsTickerState extends State<MonotonicSecondsTicker>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      setState(() => _elapsed = elapsed);
    })..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureTickerRunning());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureTickerRunning();
  }

  void _ensureTickerRunning() {
    if (!mounted) return;
    if (TickerMode.of(context) && !_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _elapsed.inMicroseconds / 1e6;
    return widget.builder(context, seconds);
  }
}
