import 'package:flutter/material.dart';

class VitalsListItem extends StatelessWidget {
  final String bloodPressure;
  final String heartRate;
  final DateTime recordedAt;

  const VitalsListItem({
    super.key,
    required this.bloodPressure,
    required this.heartRate,
    required this.recordedAt,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Blood Pressure: $bloodPressure'),
      subtitle: Text('Heart Rate: $heartRate'),
      trailing: Text('Recorded: ${recordedAt.toString()}'),
    );
  }
}
