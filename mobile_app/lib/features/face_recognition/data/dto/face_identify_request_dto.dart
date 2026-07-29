class FaceIdentifyRequestDto {
  final String imageBase64;

  const FaceIdentifyRequestDto({required this.imageBase64});

  Map<String, dynamic> toJson() => {'image_base64': imageBase64};
}
