class ListTask {
  final String id;
  final String name;
  final String memberEmail;
  final String? note;
  final DateTime startDate;
  final DateTime endDate;
  final String foodName;
  final int amount;
  final String unitName;
  final bool state;
  final String group;
  final double price;

  ListTask({
    required this.id,
    required this.name,
    required this.memberEmail,
    this.note,
    required this.startDate,
    required this.endDate,
    required this.foodName,
    required this.amount,
    required this.unitName,
    required this.state,
    required this.group,
    required this.price,
  });

  factory ListTask.fromJson(Map<String, dynamic> json) {
    return ListTask(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      memberEmail: json['memberEmail'] ?? '',
      note: json['note'],
      startDate: DateTime.parse(json['startDate'] ?? ''),
      endDate: DateTime.parse(json['endDate'] ?? ''),
      foodName: json['foodName'] ?? '',
      amount: json['amount'] ?? 0,
      unitName: json['unitName'] ?? '',
      state: json['state'] ?? false,
      group: json['group'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'memberEmail': memberEmail,
      'note': note,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'foodName': foodName,
      'amount': amount,
      'unitName': unitName,
      'state': state,
      'group': group,
      'price': price,
    };
  }
}
