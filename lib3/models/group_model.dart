import 'item_model.dart';

class GroupUser {
  final String name;
  final String email;
  final String role;

  GroupUser({
    required this.name,
    required this.email,
    required this.role,
  });

  factory GroupUser.fromJson(Map<String, dynamic> json) {
    return GroupUser(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

class Group {
  final String id;
  final String name;
  final List<GroupUser> listUser;
  final List<Item> refrigerator;
  final String? image;

  Group({
    required this.id,
    required this.name,
    required this.listUser,
    required this.refrigerator,
    this.image,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      listUser: (json['listUser'] as List<dynamic>)
          .map((user) => GroupUser.fromJson(user))
          .toList(),
      refrigerator: (json['refrigerator'] as List<dynamic>)
          .map((item) => Item.fromJson(item))
          .toList(),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'listUser': listUser.map((user) => user.toJson()).toList(),
      'refrigerator': refrigerator.map((item) => item.toJson()).toList(),
      'image': image,
    };
  }
}