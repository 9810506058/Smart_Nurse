import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VitalsListItem extends StatelessWidget {
  final String bloodPressure;
  final String heartRate;
  final String temperature;
  final String weight;
  final DateTime recordedAt;

  const VitalsListItem({
    super.key,
    required this.bloodPressure,
    required this.heartRate,
    required this.temperature,
    required this.weight,
    required this.recordedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Blood Pressure: $bloodPressure'),
            Text('Heart Rate: $heartRate'),
            Text('Temperature: $temperature'),
            Text('Weight: $weight'),
            Text(
              'Recorded: ${DateFormat('MMM d, yyyy, hh:mm a').format(recordedAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}