class Intern {
  final int id;
  final String uuid;
  final String nom;
  final String prenom;
  final String matricule;
  final DateTime dateDebutStage;
  final DateTime dateFinStage;
  final String statut;
  final String? langue;
  final DateTime? dateSuppression;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Intern({
    required this.id,
    required this.uuid,
    required this.nom,
    required this.prenom,
    required this.matricule,
    required this.dateDebutStage,
    required this.dateFinStage,
    required this.statut,
    this.langue,
    this.dateSuppression,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$prenom $nom';

  bool get isActive => statut == 'ACTIF';

  String get periodeStage {
    final debut = '${dateDebutStage.day.toString().padLeft(2, '0')}/'
        '${dateDebutStage.month.toString().padLeft(2, '0')}/'
        '${dateDebutStage.year}';
    final fin = '${dateFinStage.day.toString().padLeft(2, '0')}/'
        '${dateFinStage.month.toString().padLeft(2, '0')}/'
        '${dateFinStage.year}';
    return '$debut → $fin';
  }
}

class PaginatedInterns {
  final List<Intern> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedInterns({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
