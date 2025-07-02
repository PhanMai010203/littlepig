import '../../domain/entities/ai_response.dart';
import '../../domain/services/ai_service.dart';
import 'gemini_ai_service.dart';
import 'ai_tool_registry_service.dart';
import '../../../../core/settings/app_settings.dart';

/// Factory for creating and configuring the AI service with all tools
class AIServiceFactory {
  static AIService? _instance;
  static DatabaseToolRegistry? _toolRegistry;
  static AIToolRegistryService? _registryService;

  /// Get or create the AI service instance
  static Future<AIService> getInstance() async {
    if (_instance != null) return _instance!;

    // Create tool registry
    _toolRegistry = DatabaseToolRegistry();
    
    // Create registry service and register all tools
    _registryService = AIToolRegistryService(_toolRegistry!);
    _registryService!.registerAllTools();

    // Create AI service
    _instance = GeminiAIService(_toolRegistry!);

    // Get configuration from app settings
    final config = AIServiceConfig(
      apiKey: AppSettings.geminiApiKey,
      model: AppSettings.aiModel,
      temperature: AppSettings.aiTemperature,
      maxTokens: AppSettings.aiMaxTokens,
      toolsEnabled: AppSettings.aiEnabled,
    );

    // Initialize the service
    await _instance!.initialize(config);

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
    if (_instance == null) return;

    final config = AIServiceConfig(
      apiKey: apiKey ?? AppSettings.geminiApiKey,
      model: model ?? AppSettings.aiModel,
      temperature: temperature ?? AppSettings.aiTemperature,
      maxTokens: maxTokens ?? AppSettings.aiMaxTokens,
      toolsEnabled: toolsEnabled ?? AppSettings.aiEnabled,
    );

    await _instance!.updateConfiguration(config);
  }

  /// Get tool registry for inspection
  static DatabaseToolRegistry? get toolRegistry => _toolRegistry;

  /// Get registry service for inspection
  static AIToolRegistryService? get registryService => _registryService;

  /// Check if AI service is ready
  static bool get isReady => _instance?.isInitialized ?? false;

  /// Get available tool names
  static List<String> get availableTools => 
      _registryService?.availableToolNames ?? [];

  /// Get tool count
  static int get toolCount => _registryService?.registeredToolCount ?? 0;

  /// Dispose of the AI service
  static Future<void> dispose() async {
    await _instance?.dispose();
    _instance = null;
    _toolRegistry = null;
    _registryService = null;
  }

  /// Reset and recreate the AI service
  static Future<AIService> reset() async {
    await dispose();
    return getInstance();
  }
}