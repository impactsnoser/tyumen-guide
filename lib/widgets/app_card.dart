import 'package:flutter/material.dart';
import 'dart:ui';

import '../state/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.tint,
    this.enableBackdropBlur = false,
    this.lowMotion = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? tint;
  final bool enableBackdropBlur;
  final bool lowMotion;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    final bg = tint ?? AppColors.card;

    // Для списков (особенно на слабых телефонах) тяжелые тени/градиенты дают лаги
    // при скролле. В режиме lowMotion уменьшаем их стоимость.
    final shadow = lowMotion
        ? BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 10),
          )
        : BoxShadow(
            color: AppColors.shadow,
            blurRadius: 30,
            offset: const Offset(0, 18),
          );

    final box = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          shadow,
        ],
        border: Border.all(color: AppColors.outline),
        gradient: lowMotion
            ? LinearGradient(
                colors: [
                  bg,
                  Color.lerp(bg, AppColors.card2, 0.28)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  bg,
                  Color.lerp(bg, AppColors.card2, 0.55)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: content,
    );

    final childWidget = enableBackdropBlur
        ? ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              // Включайте только точечно: blur очень дорогой на телефонах.
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: box,
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: box,
          );

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: childWidget,
        ),
      ),
    );
  }
}

