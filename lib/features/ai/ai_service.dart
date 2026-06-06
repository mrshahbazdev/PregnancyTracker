import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Supported Bring-Your-Own-Key AI providers.
enum AiProvider { openai, gemini }

extension AiProviderInfo on AiProvider {
  String get label => switch (this) {
        AiProvider.openai => 'OpenAI (GPT)',
        AiProvider.gemini => 'Google Gemini',
      };

  String get defaultModel => switch (this) {
        AiProvider.openai => 'gpt-4o-mini',
        AiProvider.gemini => 'gemini-1.5-flash',
      };

  String get keyHint => switch (this) {
        AiProvider.openai => 'sk-...',
        AiProvider.gemini => 'AIza...',
      };
}

/// Holds the user's AI configuration. The API key itself is stored in the
/// platform secure enclave (Keychain/Keystore) and never leaves the device.
class AiConfig {
  const AiConfig({
    required this.provider,
    required this.model,
    required this.hasKey,
  });

  final AiProvider provider;
  final String model;
  final bool hasKey;

  AiConfig copyWith({AiProvider? provider, String? model, bool? hasKey}) =>
      AiConfig(
        provider: provider ?? this.provider,
        model: model ?? this.model,
        hasKey: hasKey ?? this.hasKey,
      );
}

const _kProviderKey = 'ai_provider';
const _kModelKey = 'ai_model';
const _kApiKey = 'ai_api_key';

/// Manages BYOK configuration and secure key storage.
class AiConfigNotifier extends StateNotifier<AiConfig> {
  AiConfigNotifier(this._storage)
      : super(const AiConfig(
          provider: AiProvider.openai,
          model: 'gpt-4o-mini',
          hasKey: false,
        )) {
    _load();
  }

  final FlutterSecureStorage _storage;

  Future<void> _load() async {
    final providerName = await _storage.read(key: _kProviderKey);
    final model = await _storage.read(key: _kModelKey);
    final key = await _storage.read(key: _kApiKey);
    final provider = AiProvider.values.firstWhere(
      (p) => p.name == providerName,
      orElse: () => AiProvider.openai,
    );
    state = AiConfig(
      provider: provider,
      model: model ?? provider.defaultModel,
      hasKey: key != null && key.isNotEmpty,
    );
  }

  Future<void> setProvider(AiProvider provider) async {
    await _storage.write(key: _kProviderKey, value: provider.name);
    await _storage.write(key: _kModelKey, value: provider.defaultModel);
    state = state.copyWith(provider: provider, model: provider.defaultModel);
  }

  Future<void> setModel(String model) async {
    await _storage.write(key: _kModelKey, value: model);
    state = state.copyWith(model: model);
  }

  Future<void> setApiKey(String key) async {
    await _storage.write(key: _kApiKey, value: key);
    state = state.copyWith(hasKey: key.isNotEmpty);
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: _kApiKey);
    state = state.copyWith(hasKey: false);
  }

  Future<String?> readApiKey() => _storage.read(key: _kApiKey);
}

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final aiConfigProvider =
    StateNotifierProvider<AiConfigNotifier, AiConfig>((ref) {
  return AiConfigNotifier(ref.watch(secureStorageProvider));
});

/// Thrown when an AI request cannot be completed.
class AiException implements Exception {
  AiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Sends chat messages to the user-configured provider using their own key.
class AiService {
  AiService(this._config, this._notifier);

  final AiConfig _config;
  final AiConfigNotifier _notifier;

  static const String systemPrompt =
      'You are a warm, supportive pregnancy companion assistant. '
      'Give clear, evidence-based, easy-to-understand information about pregnancy, '
      'fetal development, symptoms, nutrition and wellbeing. '
      'You are NOT a doctor: never diagnose, and always remind the user to consult '
      'their healthcare provider for medical decisions or warning signs '
      '(e.g. heavy bleeding, severe headache, reduced fetal movement). '
      'Keep answers concise and reassuring.';

  Future<String> ask(String userMessage, {String? context}) async {
    final key = await _notifier.readApiKey();
    if (key == null || key.isEmpty) {
      throw AiException('No API key set. Add your key in Settings to use the AI assistant.');
    }
    final fullSystem = context == null
        ? systemPrompt
        : '$systemPrompt\n\nUser pregnancy context: $context';

    return switch (_config.provider) {
      AiProvider.openai => _askOpenAi(key, fullSystem, userMessage),
      AiProvider.gemini => _askGemini(key, fullSystem, userMessage),
    };
  }

  Future<String> _askOpenAi(
      String key, String system, String message) async {
    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        'model': _config.model,
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': message},
        ],
        'temperature': 0.6,
      }),
    );
    if (res.statusCode != 200) {
      throw AiException(_friendlyError(res.statusCode, res.body));
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    return (choices.first as Map<String, dynamic>)['message']['content']
        as String;
  }

  Future<String> _askGemini(
      String key, String system, String message) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/${_config.model}:generateContent?key=$key';
    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': system}
          ]
        },
        'contents': [
          {
            'parts': [
              {'text': message}
            ]
          }
        ],
      }),
    );
    if (res.statusCode != 200) {
      throw AiException(_friendlyError(res.statusCode, res.body));
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>;
    final parts = (candidates.first as Map<String, dynamic>)['content']
        ['parts'] as List<dynamic>;
    return (parts.first as Map<String, dynamic>)['text'] as String;
  }

  String _friendlyError(int status, String body) {
    if (status == 401 || status == 403) {
      return 'Your API key was rejected. Please check it in Settings.';
    }
    if (status == 429) {
      return 'Rate limit or quota reached on your AI account. Try again later.';
    }
    return 'AI request failed ($status). Please try again.';
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  final config = ref.watch(aiConfigProvider);
  final notifier = ref.watch(aiConfigProvider.notifier);
  return AiService(config, notifier);
});
