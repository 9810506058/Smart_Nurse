import 'package:flutter/material.dart';
import '../models/medication_model.dart';

class MedicationListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Medication medication;
  final VoidCallback onTap;
  final Function(bool) onAdministeredChanged;

  const MedicationListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.medication,
    required this.onTap,
    required this.onAdministeredChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: Icon(icon, color: iconColor, size: 28),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: SizedBox(
            width: 100, // Fixed width for consistent alignment
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Checkbox with label
                InkWell(
                  onTap: () {
                    final newValue = !medication.isAdministered;
                    onAdministeredChanged(newValue);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: medication.isAdministered,
                        onChanged: (bool? value) {
                          if (value != null) {
                            onAdministeredChanged(value);
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        medication.isAdministered ? 'Done' : 'Mark',
                        style: TextStyle(
                          color: medication.isAdministered
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: onTap,
                ),
              ],
            ),
          ),
          onTap: onTap, // Makes entire tile tappable
        ),
      ),
    );
  }
}
