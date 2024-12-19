class Food {
  final String id;
  final String name;
  final String categoryName;
  final String unitName;
  final String? image;
  final String group;

  Food({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.unitName,
    this.image,
    required this.group,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      categoryName: json['categoryName'] ?? '',
      unitName: json['unitName'] ?? '',
      image: json['image'],
      group: json['group'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryName': categoryName,
      'unitName': unitName,
      'image': image,
      'group': group,
    };
  }
}