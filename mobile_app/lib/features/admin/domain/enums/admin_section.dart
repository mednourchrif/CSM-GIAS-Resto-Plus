import 'package:flutter/material.dart';

enum AdminSection {
  employees(Icons.people_rounded, 'Employés'),
  interns(Icons.school_rounded, 'Stagiaires'),
  visitors(Icons.group_rounded, 'Visiteurs'),
  qrCodes(Icons.qr_code_rounded, 'QR Codes'),
  faceEnrollment(Icons.face_rounded, 'Visages'),
  mealHistory(Icons.restaurant_menu_rounded, 'Repas'),
  statistics(Icons.bar_chart_rounded, 'Statistiques'),
  settings(Icons.settings_rounded, 'Paramètres');

  final IconData icon;
  final String label;

  const AdminSection(this.icon, this.label);

  String get placeholderTitle => label;

  String get placeholderDescription {
    switch (this) {
      case AdminSection.employees:
        return 'La gestion des employés sera implémentée ici.';
      case AdminSection.interns:
        return 'Gestion des stagiaires: inscription, suivi, et période de stage.';
      case AdminSection.visitors:
        return 'La gestion des visiteurs sera implémentée ici.';
      case AdminSection.qrCodes:
        return 'La gestion des QR codes sera implémentée ici.';
      case AdminSection.faceEnrollment:
        return "L'inscription des visages sera implémentée ici.";
      case AdminSection.mealHistory:
        return "L'historique des repas sera implémenté ici.";
      case AdminSection.statistics:
        return 'Les statistiques seront implémentées ici.';
      case AdminSection.settings:
        return 'Les paramètres seront implémentés ici.';
    }
  }
}
