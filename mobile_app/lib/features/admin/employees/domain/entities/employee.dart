class Employee {
  final int id;
  final String uuid;
  final String nom;
  final String prenom;
  final String? email;
  final String matricule;
  final String statut;
  final String statutEnrolement;
  final String? photoPath;
  final DateTime? dateEnrolement;
  final DateTime? dateSuppression;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Employee({
    required this.id,
    required this.uuid,
    required this.nom,
    required this.prenom,
    this.email,
    required this.matricule,
    required this.statut,
    required this.statutEnrolement,
    this.photoPath,
    this.dateEnrolement,
    this.dateSuppression,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$prenom $nom';

  bool get isActive => statut == 'ACTIF';

  bool get isEnrolled => statutEnrolement == 'ENROLE';
}

class PaginatedEmployees {
  final List<Employee> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedEmployees({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
