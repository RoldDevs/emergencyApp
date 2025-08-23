import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:emergency_app/models/chat_message.dart';

class OpenRouterService {
  final String apiKey;
  final String baseUrl = 'https://openrouter.ai/api/v1';
  final String model = 'openai/gpt-oss-20b:free';
  
  OpenRouterService({required this.apiKey});

  Future<String> readApiKey() async {
    try {
      final file = File('openrouter.api.key');
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read API key: $e');
    }
  }

  Future<ChatMessage> sendMessage(List<ChatMessage> messages) async {
    try {
      final url = Uri.parse('$baseUrl/chat/completions');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'emergency_app', // Replace with your app's URL in production
          'X-Title': 'Emergency App', // Replace with your app's name
        },
        body: jsonEncode({
          'model': model,
          'messages': messages.map((msg) => msg.toMap()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        return ChatMessage(
          content: content,
          role: MessageRole.assistant,
        );
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}

// Provider for OpenRouter service
final openRouterServiceProvider = Provider<OpenRouterService>((ref) {
  // Read API key from file
  final apiKey = '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';
  return OpenRouterService(apiKey: apiKey);
});