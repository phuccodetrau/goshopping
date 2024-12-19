class RecipeItem {
  final String foodName;
  final int amount;

  RecipeItem({
    required this.foodName,
    required this.amount,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      foodName: json['foodName'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'amount': amount,
    };
  }
}

class Recipe {
  final String id;
  final String name;
  final String? description;
  final List<RecipeItem> listItem;
  final String group;

  Recipe({
    required this.id,
    required this.name,
    this.description,
    required this.listItem,
    required this.group,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      listItem: (json['list_item'] as List<dynamic>)
          .map((item) => RecipeItem.fromJson(item))
          .toList(),
      group: json['group'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'list_item': listItem.map((item) => item.toJson()).toList(),
      'group': group,
    };
  }
}