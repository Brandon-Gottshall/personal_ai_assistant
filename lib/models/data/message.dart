class Message {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp; // Optional: to store when the message was created
  final String? messageId; // Optional: unique identifier for the message

  @override
  String toString() {
    return 'Message{text: $text, isUserMessage: $isUserMessage, timestamp: $timestamp, messageId: $messageId}';
  }

  Message({
    required this.text,
    required this.isUserMessage,
    DateTime? timestamp,
    this.messageId,
  }) : timestamp = timestamp ?? DateTime.now();

factory Message.fromJson(Map<String, dynamic> json) {
  // Extracting the first item's text value from the content list
  String messageText = '';
  if (json['content'] != null && json['content'] is List) {
    var contentList = json['content'] as List;
    if (contentList.isNotEmpty && contentList[0]['text'] != null && contentList[0]['text'] is Map) {
      messageText = contentList[0]['text']['value'] ?? '';
    }
  }

  

  return Message(
    text: messageText,
    isUserMessage: json['role'] == 'user',
    timestamp: json.containsKey('created_at') ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000) : null,
    messageId: json['id'],
  );
}

}