import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ButtonVariant { filled, outlined, text, gradient }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<Color>? gradientColors;
  final double fontSize;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 52,
    this.borderRadius = 14,
    this.backgroundColor,
    this.foregroundColor,
    this.gradientColors,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == ButtonVariant.outlined
                    ? (foregroundColor ?? AppColors.primary)
                    : Colors.white,
              ),
            ),
          )
        else ...[
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _getForegroundColor(context, disabled),
            ),
          ),
          if (suffixIcon != null) ...[
            const SizedBox(width: 8),
            suffixIcon!,
          ],
        ],
      ],
    );

    Widget button;

    switch (variant) {
      case ButtonVariant.gradient:
        button = GestureDetector(
          onTap: disabled ? null : onPressed,
          child: AnimatedOpacity(
            opacity: disabled ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: isFullWidth ? double.infinity : width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: disabled
                      ? [Colors.grey.shade400, Colors.grey.shade300]
                      : (gradientColors ?? AppColors.primaryGradient),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: disabled
                    ? null
                    : [
                        BoxShadow(
                          color: (gradientColors?.first ?? AppColors.primary)
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(child: buttonContent),
            ),
          ),
        );

      case ButtonVariant.outlined:
        button = SizedBox(
          width: isFullWidth ? double.infinity : width,
          height: height,
          child: OutlinedButton(
            onPressed: disabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: foregroundColor ?? AppColors.primary,
              side: BorderSide(
                color: disabled
                    ? Colors.grey.shade300
                    : (foregroundColor ?? AppColors.primary),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonContent,
          ),
        );

      case ButtonVariant.text:
        button = SizedBox(
          width: isFullWidth ? double.infinity : width,
          height: height,
          child: TextButton(
            onPressed: disabled ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: foregroundColor ?? AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonContent,
          ),
        );

      case ButtonVariant.filled:
      default:
        button = SizedBox(
          width: isFullWidth ? double.infinity : width,
          height: height,
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: disabled
                  ? Colors.grey.shade300
                  : (backgroundColor ?? AppColors.primary),
              foregroundColor: foregroundColor ?? Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonContent,
          ),
        );
    }

    return button;
  }

  Color _getForegroundColor(BuildContext context, bool disabled) {
    if (disabled) return Colors.grey.shade500;
    if (foregroundColor != null) return foregroundColor!;
    switch (variant) {
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return AppColors.primary;
      default:
        return Colors.white;
    }
  }
}

class SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
