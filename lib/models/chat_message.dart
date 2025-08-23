enum MessageRole {
  user,
  assistant,
  system
}

class ChatMessage {
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.isLoading = false,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to map for API request
  Map<String, dynamic> toMap() {
    return {
      'role': role.toString().split('.').last,
      'content': content,
    };
  }

  // Create a loading message
  factory ChatMessage.loading() {
    return ChatMessage(
      content: '',
      role: MessageRole.assistant,
      isLoading: true,
    );
  }
}