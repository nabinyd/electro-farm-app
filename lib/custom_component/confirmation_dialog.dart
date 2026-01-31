import 'package:electro_farm/core/utils/button_sizes.dart';
import 'package:electro_farm/core/utils/button_types.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final IconData icon;
  final ButtonType buttonType;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool loading;

  /// ✅ Optional "type to confirm"
  /// If not null, user must type this text to enable confirm.
  final String? requiredConfirmText;

  /// Optional UX text for the input
  final String confirmInputLabel;
  final String confirmInputHint;

  /// Whether match is case-sensitive
  final bool caseSensitiveConfirmText;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.buttonType,
    required this.confirmColor,
    required this.icon,
    required this.onConfirm,
    this.onCancel,
    this.cancelText = 'Cancel',
    this.loading = false,

    // ✅ new params (non-breaking)
    this.requiredConfirmText,
    this.confirmInputLabel = 'Type to confirm',
    this.confirmInputHint = '',
    this.caseSensitiveConfirmText = false,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  late final TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();
    _confirmController = TextEditingController();
    _confirmController.addListener(() {
      // Rebuild to enable/disable confirm button while typing
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  bool get _needsTypedConfirm => widget.requiredConfirmText != null;

  bool get _isTypedValid {
    if (!_needsTypedConfirm) return true;

    final typed = _confirmController.text.trim();
    final required = widget.requiredConfirmText!.trim();

    if (widget.caseSensitiveConfirmText) {
      return typed == required;
    }
    return typed.toLowerCase() == required.toLowerCase();
  }

  bool get _canConfirm => !widget.loading && _isTypedValid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !widget.loading,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.confirmColor.withValues(alpha: .12),
                ),
                child: Icon(widget.icon, size: 28, color: widget.confirmColor),
              ),

              const SizedBox(height: 16),

              /// Title
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              /// Message
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),

              /// ✅ Optional input
              if (_needsTypedConfirm) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.confirmInputLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmController,
                  enabled: !widget.loading,
                  decoration: InputDecoration(
                    hintText: widget.confirmInputHint.isNotEmpty
                        ? widget.confirmInputHint
                        : 'Type "${widget.requiredConfirmText}"',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    errorText: _confirmController.text.isEmpty || _isTypedValid
                        ? null
                        : 'Text does not match',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Required: "${widget.requiredConfirmText}"',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              /// Actions
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: widget.cancelText,
                      onPressed: () {
                        if (!widget.loading) {
                          if (widget.onCancel != null) {
                            widget.onCancel!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      type: ButtonType.outline,
                      size: ButtonSize.medium,
                      isDisabled: widget.loading,
                      isLoading: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: widget.confirmText,
                      size: ButtonSize.medium,
                      type: widget.buttonType,
                      onPressed: () {
                        if (_canConfirm) widget.onConfirm();
                      },
                      isDisabled: !_canConfirm,
                      isLoading: widget.loading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
