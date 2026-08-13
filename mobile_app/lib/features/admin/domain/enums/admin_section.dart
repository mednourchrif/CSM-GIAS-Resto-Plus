import 'package:flutter/material.dart';

enum AdminSection {
  employees(Icons.people_rounded, 'Employés'),
  interns(Icons.school_rounded, 'Stagiaires'),
  visitors(Icons.group_rounded, 'Visiteurs'),
  qrCodes(Icons.qr_code_rounded, 'QR Codes'),
  faceEnrollment(Icons.face_rounded, 'Visages'),
  mealHistory(Icons.restaurant_menu_rounded, 'Repas'),
  receipts(Icons.receipt_long_rounded, 'Reçus'),
  statistics(Icons.bar_chart_rounded, 'Statistiques'),
  reports(Icons.assessment_rounded, 'Rapports'),
  users(Icons.admin_panel_settings_rounded, 'Utilisateurs'),
  settings(Icons.settings_rounded, 'Paramètres'),
  audit(Icons.history_rounded, 'Audit');

  final IconData icon;
  final String label;

  const AdminSection(this.icon, this.label);
}
