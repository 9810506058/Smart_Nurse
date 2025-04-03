import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
  Color? backgroundColor,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      backgroundColor: backgroundColor,
    ),
  );
}

String formatTime(DateTime time) {
  return DateFormat('hh:mm a').format(time);
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('MMM d, yyyy, hh:mm a').format(dateTime);
}
