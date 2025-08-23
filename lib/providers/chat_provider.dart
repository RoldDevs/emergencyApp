import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/models/chat_message.dart';
import 'package:emergency_app/providers/openrouter_service.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final OpenRouterService _openRouterService;

  ChatNotifier(this._openRouterService)
      : super(ChatState(messages: [
          ChatMessage(
            content: 'Hello! I\'m your emergency assistant. How can I help you today?',
            role: MessageRole.assistant,
          ),
        ]));

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      content: content,
      role: MessageRole.user,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Add loading message
      state = state.copyWith(
        messages: [...state.messages, ChatMessage.loading()],
      );

      // Get response from API
      final response = await _openRouterService.sendMessage(state.messages.where((msg) => !msg.isLoading).toList());

      // Replace loading message with actual response
      final updatedMessages = state.messages.where((msg) => !msg.isLoading).toList();
      updatedMessages.add(response);

      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
      );
    } catch (e) {
      // Remove loading message and show error
      final updatedMessages = state.messages.where((msg) => !msg.isLoading).toList();
      
      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = ChatState(messages: [
      ChatMessage(
        content: 'Hello! I\'m your emergency assistant. How can I help you today?',
        role: MessageRole.assistant,
      ),
    ]);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final openRouterService = ref.watch(openRouterServiceProvider);
  return ChatNotifier(openRouterService);
});