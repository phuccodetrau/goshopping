class MealPlan {
  final String id;
  final DateTime date;
  final String course;
  final List<String> listRecipe;
  final String group;

  MealPlan({
    required this.id,
    required this.date,
    required this.course,
    required this.listRecipe,
    required this.group,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['_id'] ?? json['id'] ?? '',
      date: DateTime.parse(json['date'] ?? ''),
      course: json['course'] ?? '',
      listRecipe: List<String>.from(json['listRecipe'] ?? []),
      group: json['group'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'course': course,
      'listRecipe': listRecipe,
      'group': group,
    };
  }
}
