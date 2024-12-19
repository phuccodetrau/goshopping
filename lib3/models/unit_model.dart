class Unit {
  final String id;
  final String name;
  final String group;

  Unit({
    required this.id,
    required this.name,
    required this.group,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      group: json['group'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'group': group,
    };
  }
}