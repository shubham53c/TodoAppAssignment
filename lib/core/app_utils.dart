import 'package:flutter/material.dart';
import './app_colors.dart';

class AppUtils {
  static void showErrorSnackbar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.errorColor,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: const Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  static Future<DateTime?> showDatePickerDialog(BuildContext ctx) async {
    final DateTime? pickedDate = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(
          days: 365,
        ),
      ),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryColor,
          ),
        ),
        child: child!,
      ),
    );
    return pickedDate;
  }

  static Future<TimeOfDay?> showTimePickerDialog(BuildContext ctx) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now(),
      ),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryColor,
          ),
        ),
        child: child!,
      ),
    );
    return pickedTime;
  }
}
