class ChatUser {
  late String? name;
  late String id;
  late String? email;
  late String? imageUrl;
  late bool isOnline;
  late String? pushToken;
  late String? lastActive;
  late String? createdAT;
  late String? about;

  ChatUser({
    required this.name,
    required this.id,
    required this.email,
    required this.imageUrl,
    this.isOnline = false,
    required this.pushToken,
    required this.lastActive,
    required this.createdAT,
    required this.about,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
        name: json['name'] ?? "",
        id: json['id'] ?? "",
        email: json['email'] ?? "",
        imageUrl: json['imageUrl'] ?? "",
        pushToken: json['push_token'] ?? "",
        lastActive: json['last_active'] ?? "",
        isOnline: json['isOnline'] ?? false,
        about: json['about'] ?? "",
        createdAT: json['created_at'] ?? "");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['id'] = id;
    data['email'] = email;
    data['imageUrl'] = imageUrl;
    data['push_token'] = pushToken;
    data['isOnline'] = isOnline;
    data['last_active'] = lastActive;
    data['about'] = about;
    data['created_at'] = createdAT;
    return data;
  }
}
