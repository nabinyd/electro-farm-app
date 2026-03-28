import 'package:electro_farm/core/utils/button_sizes.dart';
import 'package:electro_farm/core/utils/button_types.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:electro_farm/providers/telemetry_provider.dart';
import 'package:electro_farm/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  List<Widget> _buildAppBarActions(BuildContext context, TelemetryProvider t) {
    final List<Widget> actionWidgets = [
      ...?actions,
      OutlinedButton(
        onPressed: () {
          if (t.status == SocketStatus.connected) {
            t.socketService.disconnect();
          } else {
            t.socketService.connect();
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onPrimary,
          side: BorderSide(color: AppColors.onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        child: Text(
          t.status == SocketStatus.connected ? "Connected" : "Disconnected",
          style: const TextStyle(color: AppColors.onPrimary),
        ),
      ),
      SizedBox(width: 8),
    ];

    return actionWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<TelemetryProvider>();
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      backgroundColor: AppColors.primary,
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
          : Container(
              margin: const EdgeInsets.only(left: 12.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/icon/electrofarm-logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            )
          : null,
      actions: _buildAppBarActions(context, t),
    );
  }
}
