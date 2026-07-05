extension StringExtension on String {
  bool get isEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  bool get isPhone {
    final phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,15}$');
    return phoneRegex.hasMatch(this);
  }

  bool get isUrl {
    final urlRegex = RegExp(r'^https?://[\w\-]+(\.[\w\-]+)+[/#?]?.*$');
    return urlRegex.hasMatch(this);
  }

  bool get isNotEmptyOrWhitespace => trim().isNotEmpty;

  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String? get nullIfEmpty => isEmpty ? null : this;
}

extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
