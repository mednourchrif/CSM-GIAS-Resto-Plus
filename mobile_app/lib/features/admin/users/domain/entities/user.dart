class AdminUser {
  final int id;
  final String uuid;
  final String nom;
  final String prenom;
  final String? email;
  final String type;
  final String statut;
  final String? roleName;
  final DateTime? derniereConnexion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdById;
  final String? updatedById;

  const AdminUser({
    required this.id,
    required this.uuid,
    required this.nom,
    required this.prenom,
    this.email,
    required this.type,
    required this.statut,
    this.roleName,
    this.derniereConnexion,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.updatedById,
  });

  String get fullName => '$prenom $nom';

  bool get isActive => statut == 'ACTIF';

  bool get isAdmin => type == 'ADMINISTRATEUR';

  String get typeLabel => isAdmin ? 'Administrateur' : 'Réceptionniste';

  String get statusLabel => isActive ? 'Actif' : 'Désactivé';
}

class PaginatedAdminUsers {
  final List<AdminUser> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedAdminUsers({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
