import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CustomButtonVariant { primary, secondary, outlined }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;
    switch (variant) {
      case CustomButtonVariant.primary:
        button = _PrimaryButton(
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
        );
      case CustomButtonVariant.secondary:
        button = _SecondaryButton(
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
        );
      case CustomButtonVariant.outlined:
        button = _OutlinedButton(
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
        );
    }

    return SizedBox(width: width, height: height, child: button);
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const _PrimaryButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.emeraldPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _ButtonContent(text: text, isLoading: isLoading, icon: icon),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const _SecondaryButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.emeraldLight,
        foregroundColor: AppTheme.emeraldPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _ButtonContent(text: text, isLoading: isLoading, icon: icon),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const _OutlinedButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.emeraldPrimary),
        foregroundColor: AppTheme.emeraldPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _ButtonContent(text: text, isLoading: isLoading, icon: icon),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String text;
  final bool isLoading;
  final IconData? icon;

  const _ButtonContent({
    required this.text,
    required this.isLoading,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(text)],
      );
    }

    return Text(text);
  }
}
