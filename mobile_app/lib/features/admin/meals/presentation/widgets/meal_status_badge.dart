import 'package:flutter/material.dart';

import '../../domain/entities/meal_history.dart';

class MealStatusBadge extends StatelessWidget {
  final TypeIdentification type;

  const MealStatusBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      TypeIdentification.face => ('Visage', Colors.green),
      TypeIdentification.qr => ('QR Code', Colors.blue),
      TypeIdentification.unknown => ('Inconnu', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
