import 'package:electro_farm/core/utils/responsive_padding.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:flutter/material.dart';

class PremiumCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? trailing;
  const PremiumCard({
    super.key,
    this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: AppPadding.allLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 10),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
