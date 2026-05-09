class Template {
  final String id;
  final String name;
  final String imageUrl;
  final int requiredPhotos;
  final int slots;
  final String? userId;
  final bool isSystem;

  Template({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.requiredPhotos,
    required this.slots,
    this.userId,
    this.isSystem = false,
  });

  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      imageUrl: map['image_url'] ?? '',
      requiredPhotos: map['required_photos'] ?? 0,
      slots: map['slots'] ?? 0,
      userId: map['user_id'],
      isSystem: map['is_system'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image_url': imageUrl,
      'required_photos': requiredPhotos,
      'slots': slots,
      'user_id': userId,
      'is_system': isSystem,
    };
  }
}
