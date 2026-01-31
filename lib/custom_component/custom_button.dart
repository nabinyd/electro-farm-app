import 'package:electro_farm/core/utils/button_sizes.dart';
import 'package:electro_farm/core/utils/button_types.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final IconData? iconData;
  final bool iconTrailing;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconData,
    this.iconTrailing = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final content = _buildContent();

    return SizedBox(
      width: width ?? _getButtonWidth(),
      height: height ?? _getButtonHeight(),
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: buttonStyle,
        child: content,
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final foregroundColor = _getForegroundColor();
    final borderColor = _getBorderColor();
    final padding = _getPadding();

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: AppColors.outline,
      disabledForegroundColor: AppColors.textSecondary,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: borderColor != null
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
      padding: padding,
    );
  }

  Color _getBackgroundColor() {
    if (isDisabled) return AppColors.outline;

    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
      case ButtonType.danger:
        return AppColors.error;
      case ButtonType.success:
        return AppColors.secondary;
    }
  }

  Color _getForegroundColor() {
    if (isDisabled) return AppColors.textSecondary;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
      case ButtonType.success:
        return AppColors.onPrimary;
      case ButtonType.outline:
      case ButtonType.text:
        return AppColors.primary;
    }
  }

  Color? _getBorderColor() {
    if (isDisabled) return AppColors.outline;

    switch (type) {
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.danger:
        return AppColors.error;
      case ButtonType.text:
        return Colors.transparent;
      default:
        return null;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getButtonHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 44;
      case ButtonSize.large:
        return 52;
    }
  }

  double? _getButtonWidth() {
    return width; // Use provided width or null for auto
  }

  Widget _buildContent() {
    if (isLoading) {
      return FittedBox(child: CircularProgressIndicator());
    }

    final textWidget = Text(
      text,
      style: TextStyle(fontSize: _getFontSize(), fontWeight: FontWeight.w600),
    );

    final iconWidget =
        icon ??
        (iconData != null ? Icon(iconData, size: _getIconSize()) : null);

    if (iconWidget == null) {
      return textWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!iconTrailing) iconWidget,
        if (!iconTrailing) const SizedBox(width: 8),
        textWidget,
        if (iconTrailing) const SizedBox(width: 8),
        if (iconTrailing) iconWidget,
      ],
    );
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }
}
