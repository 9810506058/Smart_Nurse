import 'package:flutter/material.dart';

class TaskListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const TaskListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
