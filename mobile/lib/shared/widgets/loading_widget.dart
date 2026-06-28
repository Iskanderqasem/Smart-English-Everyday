import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool isFullScreen;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.isFullScreen = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PulsingDots(color: color ?? AppColors.primary),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Scaffold(
        body: Center(child: widget),
      );
    }
    return Center(child: widget);
  }
}

class _PulsingDots extends StatelessWidget {
  final Color color;

  const _PulsingDots({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.2, 1.2),
              duration: 600.ms,
              delay: Duration(milliseconds: index * 150),
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.2, 1.2),
              end: const Offset(0.5, 0.5),
              duration: 600.ms,
              curve: Curves.easeInOut,
            ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 100,
    this.width,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final highlightColor = isDark ? AppColors.darkCard : Colors.white;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: highlightColor.withOpacity(0.6),
        );
  }
}

class OverlayLoadingWidget extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const OverlayLoadingWidget({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.overlay,
            child: LoadingWidget(message: message),
          ),
      ],
    );
  }
}
