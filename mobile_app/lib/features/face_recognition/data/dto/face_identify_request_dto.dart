class FaceIdentifyRequestDto {
  final String imageBase64;
  final String? categorieUuid;

  const FaceIdentifyRequestDto({
    required this.imageBase64,
    this.categorieUuid,
  });

  Map<String, dynamic> toJson() => {
        'image_base64': imageBase64,
        if (categorieUuid != null) 'categorie_uuid': categorieUuid,
      };
}
