import 'package:flutter/material.dart';
import '../models/patient_model.dart';

class PatientListItem extends StatelessWidget {
  final Patient patient;
  final VoidCallback? onTap;
  final VoidCallback? onAssignPressed;

  const PatientListItem({
    Key? key,
    required this.patient,
    this.onTap,
    this.onAssignPressed,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (patient.status.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'stable':
        return Colors.green;
      case 'recovering':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (patient.status.toLowerCase()) {
      case 'critical':
        return Icons.warning;
      case 'stable':
        return Icons.check_circle;
      case 'recovering':
        return Icons.trending_up;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(
                      statusIcon,
                      size: 20,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Room ${patient.roomNumber} • Bed ${patient.bedNumber}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          patient.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Conditions
              if (patient.conditions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: patient.conditions.map((condition) {
                    return Chip(
                      label: Text(
                        condition,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.blue[50],
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],

              // Notes
              if (patient.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    patient.notes,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              // Assign Button
              if (onAssignPressed != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[800],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onAssignPressed,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Assign to Nurse'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
