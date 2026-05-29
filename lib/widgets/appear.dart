import 'package:flutter/material.dart';

class Appear extends StatefulWidget {
  const Appear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.06),
    this.duration = const Duration(milliseconds: 420),
    this.enabled = true,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;
  final bool enabled;

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) {
      _show = true;
      return;
    }
    if (widget.delay == Duration.zero) {
      _show = true;
      return;
    }
    Future<void>.delayed(widget.delay, () {
      if (!mounted) return;
      setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedOpacity(
      opacity: _show ? 1 : 0,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _show ? Offset.zero : widget.offset,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

