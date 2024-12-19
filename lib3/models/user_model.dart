class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? avatar;
  final String? avatarUrl;
  final String? language;
  final String? timezone;
  final String? device;
  final String? deviceToken;
  final String? token; // For authentication

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.avatar,
    this.avatarUrl,
    this.language,
    this.timezone,
    this.device,
    this.deviceToken,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'],
      avatar: json['avatar'],
      avatarUrl: json['avatarUrl'],
      language: json['language'],
      timezone: json['timezone'],
      device: json['device'],
      deviceToken: json['deviceToken'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'avatarUrl': avatarUrl,
      'language': language,
      'timezone': timezone,
      'device': device,
      'deviceToken': deviceToken,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? avatar,
    String? avatarUrl,
    String? language,
    String? timezone,
    String? device,
    String? deviceToken,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      device: device ?? this.device,
      deviceToken: deviceToken ?? this.deviceToken,
      token: token ?? this.token,
    );
  }
} 