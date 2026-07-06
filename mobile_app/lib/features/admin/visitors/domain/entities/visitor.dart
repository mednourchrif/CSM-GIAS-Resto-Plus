class Visitor {
  final int id;
  final String uuid;
  final String nom;
  final String prenom;
  final String? email;
  final String? societe;
  final DateTime dateVisite;
  final String statut;
  final String? langue;
  final DateTime? dateSuppression;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Visitor({
    required this.id,
    required this.uuid,
    required this.nom,
    required this.prenom,
    this.email,
    this.societe,
    required this.dateVisite,
    required this.statut,
    this.langue,
    this.dateSuppression,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$prenom $nom';

  bool get isActive => statut == 'ACTIF';

  String get formattedDate {
    return '${dateVisite.day.toString().padLeft(2, '0')}/'
        '${dateVisite.month.toString().padLeft(2, '0')}/'
        '${dateVisite.year}';
  }
}

class PaginatedVisitors {
  final List<Visitor> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedVisitors({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
