import 'package:flutter/widgets.dart';

class NesuiSpin extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const NesuiSpin({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<NesuiSpin> createState() => _NesuiSpinState();
}

class _NesuiSpinState extends State<NesuiSpin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: _c, child: widget.child);
  }
}
