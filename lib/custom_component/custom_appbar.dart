import 'package:electro_farm/custom_component/constant.dart';
import 'package:flutter/material.dart';

class ElectrofarmAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final bool showUserInfo;
  final bool showLogoutButton;

  const ElectrofarmAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.bottom,
    this.showUserInfo = true,
    this.showLogoutButton = true,
  });

  @override
  Size get preferredSize {
    final baseHeight = kToolbarHeight;
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(baseHeight + bottomHeight);
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    final List<Widget> actionWidgets = [...?actions];

    if (showLogoutButton) {
      actionWidgets.add(
        IconButton(
          icon: Icon(Icons.logout_rounded, color: AppColors.onPrimary),
          onPressed: () {},
          tooltip: 'Logout',
        ),
      );
    }

    return actionWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: showBackButton,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 2,
      shadowColor: AppColors.onSurface.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
      iconTheme: IconThemeData(color: AppColors.onPrimary),
      actionsIconTheme: IconThemeData(color: AppColors.onPrimary),
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary),
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: 'Back',
            )
          : CircleAvatar(
              child: Image.asset(
                'assets/images/electrofarm_icon.png',
                height: 24,
                width: 24,
              ),
            ),
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      actions: _buildAppBarActions(context),
    );
  }
}
