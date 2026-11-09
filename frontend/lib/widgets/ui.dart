import 'package:flutter/material.dart';

class Ui {
  static const background = Color(0xFF101A1A);
  static const surface = Color(0xFF192626);
  static const border = Color(0xFF2C3D3A);
  static const green = Color(0xFFB6EF86);
  static const muted = Color(0xFFA7B8B2);
}

class PageHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  const PageHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow.toUpperCase(),
        style: const TextStyle(
          color: Ui.green,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
      ),
      const SizedBox(height: 8),
      Text(subtitle, style: const TextStyle(color: Ui.muted, height: 1.5)),
    ],
  );
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Ui.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Ui.border),
    ),
    child: child,
  );
}
