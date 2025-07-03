import 'package:flutter/material.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/services/ai_service.dart';
import 'real_gemini_ai_service.dart';
import 'gemini_ai_service.dart' show DatabaseToolRegistry;
import 'ai_tool_registry_service.dart';
import '../../../../core/settings/app_settings.dart';

/// Factory for creating and configuring the AI service with all tools
class AIServiceFactory {
  static AIService? _instance;
  static DatabaseToolRegistry? _toolRegistry;
  static AIToolRegistryService? _registryService;

  /// Get or create the AI service instance
  static Future<AIService> getInstance() async {
    debugPrint('🏭 AIServiceFactory - getInstance called');
    
    if (_instance != null) {
      debugPrint('✅ AIServiceFactory - Returning existing instance');
      return _instance!;
    }

    debugPrint('🏗️ AIServiceFactory - Creating new AI service instance');

    // Create tool registry
    debugPrint('🛠️ AIServiceFactory - Creating tool registry');
    _toolRegistry = DatabaseToolRegistry();
    
    // Create registry service and register all tools
    debugPrint('📝 AIServiceFactory - Creating registry service');
    _registryService = AIToolRegistryService(_toolRegistry!);
    
    debugPrint('📝 AIServiceFactory - Registering all tools');
    _registryService!.registerAllTools();
    debugPrint('✅ AIServiceFactory - All tools registered');

    // Create AI service
    debugPrint('🤖 AIServiceFactory - Creating RealGeminiAIService');
    _instance = RealGeminiAIService(_toolRegistry!);

    // Get configuration from app settings
    debugPrint('⚙️ AIServiceFactory - Loading configuration from app settings');
    final config = AIServiceConfig(
      apiKey: AppSettings.geminiApiKey,
      model: AppSettings.aiModel,
      temperature: AppSettings.aiTemperature,
      maxTokens: AppSettings.aiMaxTokens,
      toolsEnabled: AppSettings.aiEnabled,
    );

    debugPrint('⚙️ Configuration details:');
    debugPrint('  - API Key: ${config.apiKey.isNotEmpty ? "Provided (${config.apiKey.length} chars)" : "Not provided"}');
    debugPrint('  - Model: ${config.model}');
    debugPrint('  - Temperature: ${config.temperature}');
    debugPrint('  - Max Tokens: ${config.maxTokens}');
    debugPrint('  - Tools Enabled: ${config.toolsEnabled}');

    // Initialize the service
    debugPrint('🚀 AIServiceFactory - Initializing AI service');
    await _instance!.initialize(config);
    debugPrint('✅ AIServiceFactory - AI service initialized successfully');

    return _instance!;
  }

  /// Update AI service configuration
  static Future<void> updateConfiguration({
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
    bool? toolsEnabled,
  }) async {
    debugPrint('🔧 AIServiceFactory - updateConfiguration called');
    
    if (_instance == null) {
      debugPrint('⚠️ AIServiceFactory - No instance to update, skipping');
      return;
    }

    debugPrint('🔧 Configuration update details:');
    if (apiKey != null) debugPrint('  - API Key: Updated (${apiKey.length} chars)');
    if (model != null) debugPrint('  - Model: $model');
    if (temperature != null) debugPrint('  - Temperature: $temperature');
    if (maxTokens != null) debugPrint('  - Max Tokens: $maxTokens');
    if (toolsEnabled != null) debugPrint('  - Tools Enabled: $toolsEnabled');

    final config = AIServiceConfig(
      apiKey: apiKey ?? AppSettings.geminiApiKey,
      model: model ?? AppSettings.aiModel,
      temperature: temperature ?? AppSettings.aiTemperature,
      maxTokens: maxTokens ?? AppSettings.aiMaxTokens,
      toolsEnabled: toolsEnabled ?? AppSettings.aiEnabled,
    );

    debugPrint('🔧 AIServiceFactory - Applying configuration update');
    await _instance!.updateConfiguration(config);
    debugPrint('✅ AIServiceFactory - Configuration updated successfully');
  }

  /// Get tool registry for inspection
  static DatabaseToolRegistry? get toolRegistry => _toolRegistry;

  /// Get registry service for inspection
  static AIToolRegistryService? get registryService => _registryService;

  /// Check if AI service is ready
  static bool get isReady {
    final ready = _instance != null && _instance!.isInitialized;
    debugPrint('🔍 AIServiceFactory - isReady: $ready');
    return ready;
  }

  /// Get available tool names
  static List<String> get availableToolNames {
    final names = _toolRegistry?.availableTools.map((tool) => tool.name).toList() ?? [];
    debugPrint('🔍 AIServiceFactory - availableToolNames: ${names.length} tools');
    for (int i = 0; i < names.length; i++) {
      debugPrint('  ${i + 1}. ${names[i]}');
    }
    return names;
  }

  /// Get tool count
  static int get toolCount {
    final count = _toolRegistry?.availableTools.length ?? 0;
    debugPrint('🔍 AIServiceFactory - toolCount: $count');
    return count;
  }

  /// Dispose of the AI service
  static Future<void> dispose() async {
    debugPrint('🗑️ AIServiceFactory - Disposing resources');
    
    if (_instance != null) {
      debugPrint('🗑️ Disposing AI service instance');
      await _instance!.dispose();
      _instance = null;
    }

    if (_toolRegistry != null) {
      debugPrint('🗑️ Clearing tool registry');
      _toolRegistry = null;
    }

    if (_registryService != null) {
      debugPrint('🗑️ Clearing registry service');
      _registryService = null;
    }

    debugPrint('✅ AIServiceFactory - All resources disposed');
  }

  /// Reset and recreate the AI service
  static Future<void> reset() async {
    debugPrint('🔄 AIServiceFactory - Resetting factory');
    await dispose();
    debugPrint('✅ AIServiceFactory - Reset completed');
  }

  /// Debug information
  static void printDebugInfo() {
    debugPrint('🔍 AIServiceFactory - Debug Information:');
    debugPrint('  - Instance created: ${_instance != null}');
    debugPrint('  - Instance initialized: ${_instance?.isInitialized ?? false}');
    debugPrint('  - Tool registry created: ${_toolRegistry != null}');
    debugPrint('  - Registry service created: ${_registryService != null}');
    debugPrint('  - Available tools: ${toolCount}');
    debugPrint('  - Is ready: $isReady');
  }
}