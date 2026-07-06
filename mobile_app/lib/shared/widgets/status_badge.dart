import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Map<String, (Color, String)>? customLabels;

  const StatusBadge({super.key, required this.status, this.customLabels});

  @override
  Widget build(BuildContext context) {
    final labels = customLabels ?? _defaultLabels;
    final entry = labels.entries.firstWhere(
      (e) => e.key == status.toUpperCase(),
      orElse: () => const MapEntry('_default', (Colors.grey, 'Inconnu')),
    );
    final color = entry.value.$1;
    final label = entry.value.$2;

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

const Map<String, (Color, String)> _defaultLabels = {
  'ACTIF': (Colors.green, 'Actif'),
  'INACTIF': (Colors.orange, 'Inactif'),
  'SUPPRIME': (Colors.red, 'Supprimé'),
  '_default': (Colors.grey, 'Inconnu'),
};
