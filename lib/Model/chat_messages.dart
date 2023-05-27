class ChatMessage {
  final String fromId;
  final String toId;
  final String sent;
  final String? read;
  final MessageType type;
  final String message;

  ChatMessage({
    required this.fromId,
    required this.toId,
    required this.sent,
    required this.read,
    required this.type,
    required this.message,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      fromId: json['fromId'].toString(),
      toId: json['toId'].toString(),
      sent: (json['sent']).toString(),
      read: (json['read']).toString(),
      type: (json['type']).toString() == MessageType.image.name
          ? MessageType.image
          : MessageType.text,
      message: json['msg'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['fromId'] = fromId;
    data['read'] = read;
    data['sent'] = sent;
    data['type'] = type.name;
    data['msg'] = message;
    return data;
  }
}

enum MessageType {
  text,
  image,
}
