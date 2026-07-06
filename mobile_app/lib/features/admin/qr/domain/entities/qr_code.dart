class QrCode {
  final int id;
  final String uuid;
  final String qrHash;
  final String proprietaireUuid;
  final String typeProprietaire;
  final String statut;
  final DateTime dateExpiration;
  final String? creeParUuid;
  final DateTime? dateRevocation;
  final String? revoqueParUuid;
  final String? motifRevocation;
  final DateTime? derniereValidation;
  final int nombreValidations;
  final String? metadataJson;
  final String? qrBase64;
  final String? proprietaireNom;
  final String? proprietairePrenom;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QrCode({
    required this.id,
    required this.uuid,
    required this.qrHash,
    required this.proprietaireUuid,
    required this.typeProprietaire,
    required this.statut,
    required this.dateExpiration,
    this.creeParUuid,
    this.dateRevocation,
    this.revoqueParUuid,
    this.motifRevocation,
    this.derniereValidation,
    this.nombreValidations = 0,
    this.metadataJson,
    this.qrBase64,
    this.proprietaireNom,
    this.proprietairePrenom,
    this.createdAt,
    this.updatedAt,
  });

  String get proprietaireFullName {
    if (proprietaireNom != null && proprietairePrenom != null) {
      return '${proprietairePrenom} ${proprietaireNom}';
    }
    return proprietaireUuid;
  }

  bool get isActive => statut == 'ACTIF';

  bool get isExpired => statut == 'EXPIRE';

  bool get isRevoked => statut == 'REVOQUE';

  String get typeLabel {
    switch (typeProprietaire) {
      case 'STAGIAIRE':
        return 'Stagiaire';
      case 'VISITEUR':
        return 'Visiteur';
      default:
        return typeProprietaire;
    }
  }
}

class PaginatedQrCodes {
  final List<QrCode> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedQrCodes({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
