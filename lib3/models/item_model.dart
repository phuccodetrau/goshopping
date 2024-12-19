class Item {
  final String id;
  final String foodName;
  final DateTime expireDate;
  final int amount;
  final String unitName;
  final String? note;
  final String group;

  Item({
    required this.id,
    required this.foodName,
    required this.expireDate,
    required this.amount,
    required this.unitName,
    this.note,
    required this.group,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] ?? json['id'] ?? '',
      foodName: json['foodName'] ?? '',
      expireDate: DateTime.parse(json['expireDate'] ?? ''),
      amount: json['amount'] ?? 0,
      unitName: json['unitName'] ?? '',
      note: json['note'],
      group: json['group'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'expireDate': expireDate.toIso8601String(),
      'amount': amount,
      'unitName': unitName,
      'note': note,
      'group': group,
    };
  }
}
