import 'package:flutter/material.dart';

class Ui {
  static const background = Color(0xFF101A1A);
  static const surface = Color(0xFF192626);
  static const border = Color(0xFF2C3D3A);
  static const green = Color(0xFFB6EF86);
  static const muted = Color(0xFFA7B8B2);

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const AppColors(
          background,
          surface,
          border,
          green,
          muted,
          Colors.white,
          background,
        )
      : const AppColors(
          Color(0xFFF4F7F4),
          Colors.white,
          Color(0xFFD8E2DA),
          Color(0xFF326B36),
          Color(0xFF53655B),
          Color(0xFF18291E),
          Colors.white,
        );
}

class AppColors {
  final Color background, surface, border, green, muted, text, onAccent;
  bool get isDark => background == Ui.background;
  Color get blue => isDark ? const Color(0xFF8BCBEB) : const Color(0xFF006B91);
  Color get amber => isDark ? const Color(0xFFE8C783) : const Color(0xFF805500);
  Color get danger =>
      isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E);
  const AppColors(
    this.background,
    this.surface,
    this.border,
    this.green,
    this.muted,
    this.text,
    this.onAccent,
  );
}

void showNotice(BuildContext context, String message, {bool isError = true}) {
  final width = MediaQuery.sizeOf(context).width;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        left: width >= 700 ? width - 376 : 16,
        right: 16,
        bottom: 16,
      ),
      backgroundColor: isError
          ? const Color(0xFF352B29)
          : const Color(0xFF243B2C),
      showCloseIcon: true,
      closeIconColor: Colors.white70,
      duration: const Duration(seconds: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Ui.of(context).border),
      ),
      content: Row(
        children: [
          Icon(
            isError ? Icons.info_outline : Icons.check_circle_outline,
            color: isError ? const Color(0xFFFFB4AB) : Ui.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const InlineError({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              height: 1.5,
            ),
          ),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
        ],
      ),
    ),
  );
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
        style: TextStyle(
          color: Ui.of(context).green,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        title,
        style: TextStyle(
          color: Ui.of(context).text,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: TextStyle(color: Ui.of(context).muted, height: 1.5),
      ),
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
      color: Ui.of(context).surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Ui.of(context).border),
    ),
    child: child,
  );
}
