import 'package:flutter/material.dart';
import 'package:smartnurse/screens/PatientDetailsScreen';

class PatientListItem extends StatelessWidget {
  final String initials;
  final Color backgroundColor;
  final String name;
  final String details;
  final String patientId;

  const PatientListItem({
    super.key,
    required this.initials,
    required this.backgroundColor,
    required this.name,
    required this.details,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: backgroundColor,
          child: Text(initials, style: TextStyle(color: Colors.white)),
        ),
        title: Text(name),
        subtitle: Text(details),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PatientDetailsScreen(patientId: patientId),
              ),
            );
          },
        ),
      ),
    );
  }
}
