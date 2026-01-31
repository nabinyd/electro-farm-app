import 'package:electro_farm/custom_component/constant.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static void showSuccessToast(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 14.0,
    bool showLeadingIcon = true,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor ?? AppColors.secondary,
      textColor: textColor ?? AppColors.onPrimary,
      fontSize: fontSize,
      webShowClose: true,
      timeInSecForIosWeb: _getToastDuration(toastLength),
    );
  }

  static void showPrimaryToast(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 14.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor ?? AppColors.primary,
      textColor: textColor ?? AppColors.onPrimary,
      fontSize: fontSize,
      webShowClose: true,
      timeInSecForIosWeb: _getToastDuration(toastLength),
    );
  }

  // Warning Toast
  static void showWarningToast(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 14.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor ?? AppColors.warning,
      textColor: textColor ?? AppColors.onSurface,
      fontSize: fontSize,
      webShowClose: true,
      timeInSecForIosWeb: _getToastDuration(toastLength),
    );
  }

  // Error Toast
  static void showErrorToast(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_LONG,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 14.0,
    bool showLeadingIcon = true,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor ?? AppColors.error,
      textColor: textColor ?? AppColors.onPrimary,
      fontSize: fontSize,
      webShowClose: true,
      timeInSecForIosWeb: _getToastDuration(toastLength),
    );
  }

  static void showInfoToast(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 14.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor ?? AppColors.info,
      textColor: textColor ?? AppColors.onPrimary,
      fontSize: fontSize,
      webShowClose: true,
      timeInSecForIosWeb: _getToastDuration(toastLength),
    );
  }

  static int _getToastDuration(Toast toastLength) {
    switch (toastLength) {
      case Toast.LENGTH_SHORT:
        return 2;
      case Toast.LENGTH_LONG:
        return 4;
    }
  }
}
