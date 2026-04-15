import 'package:flutter/material.dart';

/// Widget de header avec dégradé violet vers rose/magenta
class GradientHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Alignment begin;
  final Alignment end;

  const GradientHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 50, 20, 55),
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF5D38FF), Color(0xFFEE1289)],
        ),
      ),
      child: child,
    );
  }
}
