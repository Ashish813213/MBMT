import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/ai_chat_message.dart';

/// Thrown for any assistant failure (missing key, network, bad response) with
/// a message that is safe and useful to show directly in the UI.
class AiServiceException implements Exception {
  final String message;
  const AiServiceException(this.message);
  @override
  String toString() => message;
}

/// Talks to the OpenAI REST API directly over `http` - no SDK. Two
/// capabilities are used by the MBMT Assistant:
///   - [chatWithTools]: Chat Completions with one or more function tools, for
///     the trip-planning and booking conversation.
///   - [transcribe]: Whisper speech-to-text for the voice input feature.
///
/// The API key and model names are read at *build* time via `--dart-define`
/// so they are never written into source or committed to the repo. See
/// README.md for how to run with the assistant enabled.
class AiService {
  AiService._();
  static final AiService instance = AiService._();

  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _chatModel =
      String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');
  static const String _transcribeModel =
      String.fromEnvironment('OPENAI_TRANSCRIBE_MODEL', defaultValue: 'whisper-1');

  static const String _chatEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _transcribeEndpoint = 'https://api.openai.com/v1/audio/transcriptions';

  bool get isConfigured => _apiKey.isNotEmpty;

  Map<String, String> get _authHeaders => <String, String>{
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

  /// One assistant turn that may use any of [tools] (Chat Completions
  /// function-tool definitions, e.g. `{"type":"function","function":{...}}`).
  ///
  /// If the model asks to call one or more tools, [onToolCall] is invoked
  /// once per call with the tool's name and parsed JSON arguments, and must
  /// return a JSON-encodable result; every result is sent back to the model
  /// in a second request to produce the final natural-language reply, which
  /// is what this method returns.
  Future<String> chatWithTools({
    required String systemPrompt,
    required List<AiChatMessage> history,
    required String userMessage,
    required List<Map<String, dynamic>> tools,
    required Future<Map<String, dynamic>> Function(String name, Map<String, dynamic> arguments)
        onToolCall,
  }) async {
    _requireConfigured();

    final List<Map<String, dynamic>> messages = <Map<String, dynamic>>[
      <String, dynamic>{'role': 'system', 'content': systemPrompt},
      for (final AiChatMessage m in history)
        <String, dynamic>{'role': m.apiRole, 'content': m.content},
      <String, dynamic>{'role': 'user', 'content': userMessage},
    ];

    final Map<String, dynamic> first = await _postChat(messages: messages, tools: tools);

    final Map<String, dynamic> firstMessage =
        (first['choices'] as List<dynamic>).first as Map<String, dynamic>;
    final Map<String, dynamic> assistantMessage =
        firstMessage['message'] as Map<String, dynamic>;
    final List<dynamic>? toolCalls = assistantMessage['tool_calls'] as List<dynamic>?;

    if (toolCalls == null || toolCalls.isEmpty) {
      return _extractText(assistantMessage);
    }

    messages.add(<String, dynamic>{
      'role': 'assistant',
      'content': assistantMessage['content'],
      'tool_calls': toolCalls,
    });

    for (final dynamic rawCall in toolCalls) {
      final Map<String, dynamic> call = rawCall as Map<String, dynamic>;
      final Map<String, dynamic> fn = call['function'] as Map<String, dynamic>;
      final String name = (fn['name'] as String?) ?? '';
      final String argsRaw = (fn['arguments'] as String?) ?? '{}';

      Map<String, dynamic> arguments;
      try {
        final Object? decoded = jsonDecode(argsRaw);
        arguments = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      } catch (_) {
        arguments = <String, dynamic>{};
      }

      final Map<String, dynamic> toolResult = await onToolCall(name, arguments);

      messages.add(<String, dynamic>{
        'role': 'tool',
        'tool_call_id': call['id'],
        'content': jsonEncode(toolResult),
      });
    }

    final Map<String, dynamic> second = await _postChat(messages: messages);
    final Map<String, dynamic> secondChoice =
        (second['choices'] as List<dynamic>).first as Map<String, dynamic>;
    return _extractText(secondChoice['message'] as Map<String, dynamic>);
  }

  /// A plain conversational turn with no tool available (used for quick,
  /// ungrounded Q&A such as the Help & Support fallback).
  Future<String> chat({
    required String systemPrompt,
    required List<AiChatMessage> history,
    required String userMessage,
  }) async {
    _requireConfigured();
    final List<Map<String, dynamic>> messages = <Map<String, dynamic>>[
      <String, dynamic>{'role': 'system', 'content': systemPrompt},
      for (final AiChatMessage m in history)
        <String, dynamic>{'role': m.apiRole, 'content': m.content},
      <String, dynamic>{'role': 'user', 'content': userMessage},
    ];
    final Map<String, dynamic> response = await _postChat(messages: messages);
    final Map<String, dynamic> choice =
        (response['choices'] as List<dynamic>).first as Map<String, dynamic>;
    return _extractText(choice['message'] as Map<String, dynamic>);
  }

  /// Transcribes a short recorded audio [file] via OpenAI Whisper. Works for
  /// English, Hindi, Marathi and most other languages - Whisper detects the
  /// spoken language automatically.
  Future<String> transcribe(File file) async {
    _requireConfigured();

    http.StreamedResponse streamed;
    try {
      final http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(_transcribeEndpoint))
            ..headers['Authorization'] = 'Bearer $_apiKey'
            ..fields['model'] = _transcribeModel
            ..files.add(await http.MultipartFile.fromPath('file', file.path));
      streamed = await request.send().timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AiServiceException(
        'Could not reach the transcription service. Check your connection and try again.',
      );
    }

    final http.Response response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw AiServiceException('Transcription failed: ${_errorDetail(response)}');
    }

    try {
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      final String text = (body['text'] as String?)?.trim() ?? '';
      if (text.isEmpty) {
        throw const AiServiceException('Could not hear anything in that recording. Try again.');
      }
      return text;
    } catch (e) {
      if (e is AiServiceException) rethrow;
      throw const AiServiceException('Could not read the transcription response.');
    }
  }

  // --- internals -------------------------------------------------------------

  void _requireConfigured() {
    if (!isConfigured) {
      throw const AiServiceException(
        'The AI assistant is not configured. Run the app with '
        '--dart-define=OPENAI_API_KEY=... to enable it (see README.md).',
      );
    }
  }

  Future<Map<String, dynamic>> _postChat({
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async {
    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_chatEndpoint),
            headers: _authHeaders,
            body: jsonEncode(<String, dynamic>{
              'model': _chatModel,
              'messages': messages,
              'temperature': 0.4,
              'max_tokens': 500,
              if (tools != null) 'tools': tools,
              if (tools != null) 'tool_choice': 'auto',
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AiServiceException(
        'Could not reach the assistant. Check your connection and try again.',
      );
    }

    if (response.statusCode != 200) {
      throw AiServiceException('Assistant request failed: ${_errorDetail(response)}');
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const AiServiceException('Could not read the assistant\'s response.');
    }
  }

  String _extractText(Map<String, dynamic> message) {
    final String content = (message['content'] as String?)?.trim() ?? '';
    if (content.isEmpty) {
      throw const AiServiceException('The assistant returned an empty response.');
    }
    return content;
  }

  String _errorDetail(http.Response response) {
    try {
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      final Object? err = body['error'];
      if (err is Map && err['message'] is String) return err['message'] as String;
    } catch (_) {
      // fall through
    }
    return 'HTTP ${response.statusCode}';
  }
}
