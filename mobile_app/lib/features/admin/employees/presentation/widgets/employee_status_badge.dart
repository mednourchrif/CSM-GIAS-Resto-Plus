import 'package:flutter/material.dart';

class EmployeeStatusBadge extends StatelessWidget {
  final String status;

  const EmployeeStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status.toUpperCase()) {
      'ACTIF' => (Colors.green, 'Actif'),
      'INACTIF' => (Colors.orange, 'Inactif'),
      'SUPPRIME' => (Colors.red, 'Supprimé'),
      'NON_ENROLE' => (Colors.grey, 'Non enrolé'),
      'ENROLE' => (Colors.blue, 'Enrolé'),
      'ENROLEMENT_ECHOUE' => (Colors.red, 'Échec enrôlement'),
      _ => (Colors.grey, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
