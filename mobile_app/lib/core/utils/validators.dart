import '../errors/failures.dart';
import 'extensions.dart';

abstract final class Validators {
  static ValidationFailure? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationFailure(message: 'L\'email est requis.');
    }
    if (!value.trim().isEmail) {
      return const ValidationFailure(message: 'Format d\'email invalide.');
    }
    return null;
  }

  static ValidationFailure? password(String? value) {
    if (value == null || value.isEmpty) {
      return const ValidationFailure(message: 'Le mot de passe est requis.');
    }
    if (value.length < 8) {
      return const ValidationFailure(
        message: 'Le mot de passe doit contenir au moins 8 caractères.',
      );
    }
    return null;
  }

  static ValidationFailure? required(
    String? value, {
    String fieldName = 'Ce champ',
  }) {
    if (value == null || value.trim().isEmpty) {
      return ValidationFailure(message: '$fieldName est requis.');
    }
    return null;
  }

  static ValidationFailure? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Le numéro de téléphone est requis.',
      );
    }
    if (!value.trim().isPhone) {
      return const ValidationFailure(message: 'Format de téléphone invalide.');
    }
    return null;
  }

  static ValidationFailure? minLength(
    String? value, {
    required int min,
    String? fieldName,
  }) {
    if (value == null || value.length < min) {
      final name = fieldName ?? 'Ce champ';
      return ValidationFailure(
        message: '$name doit contenir au moins $min caractères.',
      );
    }
    return null;
  }

  static ValidationFailure? maxLength(
    String? value, {
    required int max,
    String? fieldName,
  }) {
    if (value != null && value.length > max) {
      final name = fieldName ?? 'Ce champ';
      return ValidationFailure(
        message: '$name ne doit pas dépasser $max caractères.',
      );
    }
    return null;
  }
}
