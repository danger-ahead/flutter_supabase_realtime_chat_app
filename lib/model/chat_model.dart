class ChatData {
  final String chat;
  final DateTime createdAt;
  final String id;
  final String username;
  final String chatId;

  ChatData(
      {required this.chat,
      required this.createdAt,
      required this.id,
      required this.username,
      required this.chatId});

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      chat: json['chat'],
      createdAt: DateTime.parse(json['created_at']),
      id: json['id'],
      username: json['username'],
      chatId: json['chat_id'],
    );
  }
}
