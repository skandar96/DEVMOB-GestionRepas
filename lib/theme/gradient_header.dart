import 'package:flutter/material.dart';

/// Palette de couleurs pour les dégradés
class GradientPalette {
  static List<Color> colors = [
    const Color.fromARGB(163, 94, 142, 253).withOpacity(1.0), // Blue
    const Color.fromARGB(227, 181, 92, 245).withOpacity(1.0), // Purple
    const Color.fromARGB(230, 254, 126, 192).withOpacity(1.0), // Pink
  ];

  static const List<double> stops = [0.0, 0.7, 1.0];
}

/// Widget de header avec dégradé 3 couleurs
class GradientHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Alignment begin;
  final Alignment end;

  const GradientHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 50, 20, 55),
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: GradientPalette.colors,
          stops: GradientPalette.stops,
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }
}