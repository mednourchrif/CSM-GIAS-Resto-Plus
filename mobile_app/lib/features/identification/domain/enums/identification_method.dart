enum IdentificationMethod {
  face,
  qr;

  String get label {
    switch (this) {
      case IdentificationMethod.face:
        return 'Reconnaissance faciale';
      case IdentificationMethod.qr:
        return 'Scanner un QR Code';
    }
  }

  String get subtitle {
    switch (this) {
      case IdentificationMethod.face:
        return 'Employés enregistrés';
      case IdentificationMethod.qr:
        return 'Visiteurs et stagiaires';
    }
  }
}
