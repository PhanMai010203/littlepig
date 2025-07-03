import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_tool_call.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/services/ai_service.dart';
import 'gemini_ai_service.dart' show DatabaseToolRegistry;
import 'ai_error_handler.dart';

/// Real implementation of AIService using Google Generative AI (Gemini)
/// This replaces the placeholder implementation with actual Gemini API calls
class RealGeminiAIService implements AIService {
  GenerativeModel? _model;
  AIServiceConfig? _config;
  final DatabaseToolRegistry _toolRegistry;
  final _uuid = const Uuid();
  bool _isInitialized = false;
  ChatSession? _chatSession;

  RealGeminiAIService(this._toolRegistry) {
    debugPrint('[RealGeminiAI] Constructor called');
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isConfigured => _config != null;

  @override
  Future<void> initialize(AIServiceConfig config) async {
    debugPrint('[RealGeminiAI] Starting initialization...');
    debugPrint('[RealGeminiAI] API Key provided: ${config.apiKey.isNotEmpty ? "Yes (${config.apiKey.length} chars)" : "No"}');
    debugPrint('[RealGeminiAI] Model: ${config.model}');
    debugPrint('[RealGeminiAI] Temperature: ${config.temperature}');
    debugPrint('[RealGeminiAI] Max Tokens: ${config.maxTokens}');
    debugPrint('[RealGeminiAI] Tools Enabled: ${config.toolsEnabled}');
    
    try {
      _config = config;
      
      // Validate configuration
      final validationErrors = AIErrorHandler.validateConfiguration(
        apiKey: config.apiKey,
        model: config.model,
        temperature: config.temperature,
        maxTokens: config.maxTokens,
      );
      
      if (validationErrors.isNotEmpty) {
        debugPrint('[RealGeminiAI] Configuration validation failed: ${validationErrors.join(', ')}');
        throw Exception('Configuration errors: ${validationErrors.join(', ')}');
      }

      debugPrint('[RealGeminiAI] Configuration validation passed');

      // Build tools for Gemini
      final geminiTools = _buildGeminiTools();
      debugPrint('[RealGeminiAI] Built ${geminiTools.length} Gemini tools');
      
      // Initialize Gemini model with function calling capabilities
      debugPrint('[RealGeminiAI] Initializing Gemini model with function calling...');
      _model = GenerativeModel(
        model: config.model,
        apiKey: config.apiKey,
        tools: geminiTools,
        generationConfig: GenerationConfig(
          temperature: config.temperature,
          maxOutputTokens: config.maxTokens,
        ),
        systemInstruction: Content.system(_buildSystemPrompt()),
      );

      // Start a new chat session for conversation context
      debugPrint('[RealGeminiAI] Starting Gemini chat session...');
      _chatSession = _model!.startChat();
      
      _isInitialized = true;
      debugPrint('[RealGeminiAI] Initialization completed successfully');
    } catch (e) {
      debugPrint('[RealGeminiAI] Initialization failed: $e');
      throw Exception('Failed to initialize Gemini AI service: ${AIErrorHandler.handleError(e)}');
    }
  }

  @override
  Stream<AIResponse> sendMessageStream(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  }) async* {
    debugPrint('[RealGeminiAI] sendMessageStream called');
    debugPrint('[RealGeminiAI] User message: "$message"');
    debugPrint('[RealGeminiAI] Conversation history length: ${conversationHistory?.length ?? 0}');
    
    if (!isInitialized || _chatSession == null) {
      debugPrint('[RealGeminiAI] ERROR: AI service not initialized or chat session null');
      throw StateError('AI service not initialized');
    }

    try {
      // Apply rate limiting
      debugPrint('[RealGeminiAI] Checking rate limit...');
      await AIErrorHandler.checkRateLimit('sendMessageStream');
      debugPrint('[RealGeminiAI] Rate limit check passed');
      
      // Log request
      try {
        final historyJson = _chatSession?.history.map((c) => c.toJson()).toList() ?? [];
        debugPrint('[RealGeminiAI] Gemini Request - New Message: "$message"');
        debugPrint('[RealGeminiAI] Gemini Request - History Length: ${historyJson.length}');
        // Uncomment the line below for extremely verbose logging of the entire conversation history
        // debugPrint('[RealGeminiAI] Gemini Request - Full History JSON: ${jsonEncode(historyJson)}');
      } catch (e) {
        debugPrint('[RealGeminiAI] Error logging request JSON: $e');
      }
      
      final responseId = _uuid.v4();
      debugPrint('[RealGeminiAI] Generated response ID: $responseId');
      
      // Send message to Gemini with retry logic
      debugPrint('[RealGeminiAI] Sending message to Gemini API...');
      final response = await AIErrorHandler.executeWithRetry(() async {
        debugPrint('[RealGeminiAI] Executing API call (with retry logic)');
        return _chatSession!.sendMessageStream(Content.text(message));
      });
      debugPrint('[RealGeminiAI] Gemini API call initiated successfully');

      String accumulatedContent = '';
      List<AIToolCall> toolCalls = [];
      bool hasToolCalls = false;
      int chunkCount = 0;

      await for (final chunk in response) {
        chunkCount++;
        debugPrint('[RealGeminiAI] Processing chunk #$chunkCount');
        
        // Debug: Log complete chunk information
        try {
          debugPrint('[RealGeminiAI] RAW_CHUNK_$chunkCount: {text: "${chunk.text}", functionCalls: ${chunk.functionCalls.length}, candidates: ${chunk.candidates?.length ?? 0}}');
          if (chunk.functionCalls.isNotEmpty) {
            for (int i = 0; i < chunk.functionCalls.length; i++) {
              final fc = chunk.functionCalls.elementAt(i);
              debugPrint('[RealGeminiAI] RAW_FUNCTION_CALL_$i: {name: "${fc.name}", args: ${jsonEncode(fc.args)}}');
            }
          }
        } catch (e) {
          debugPrint('[RealGeminiAI] Error logging chunk details: $e');
        }
        
        // Handle tool calls if present
        if (chunk.functionCalls.isNotEmpty && !hasToolCalls) {
          hasToolCalls = true;
          debugPrint('[RealGeminiAI] Function calls detected: ${chunk.functionCalls.length}');
          
          // Process function calls
          final functionCallsList = chunk.functionCalls.toList();
          for (int i = 0; i < functionCallsList.length; i++) {
            final functionCall = functionCallsList[i];
            debugPrint('[RealGeminiAI] Processing function call ${i + 1}/${functionCallsList.length}: ${functionCall.name}');
            debugPrint('[RealGeminiAI] Function arguments: ${jsonEncode(functionCall.args)}');
            
            final toolCall = AIToolCall(
              id: _uuid.v4(),
              name: functionCall.name,
              arguments: functionCall.args,
            );
            toolCalls.add(toolCall);

            // Execute the tool
            debugPrint('[RealGeminiAI] Executing tool: ${toolCall.name}');
            var toolResult = await _toolRegistry.executeTool(toolCall);
            debugPrint('[RealGeminiAI] Tool execution result - Success: ${toolResult.success}');

            // --- BEGIN ENHANCED RETRY LOGIC for create_transaction ---
            if (toolCall.name == 'create_transaction' &&
                toolResult.success &&
                (toolResult.result as Map<String, dynamic>)['success'] == false) {
              
              final error = (toolResult.result as Map<String, dynamic>)['error'] as String?;
              var recoveryAttempted = false;
              var autoCreatedItems = <String>[];
              
              if (error != null) {
                debugPrint('[RealGeminiAI] create_transaction failed: $error. Attempting comprehensive recovery...');
                
                // Handle missing category
                if (error.contains('Category with ID') && error.contains('does not exist')) {
                  debugPrint('[RealGeminiAI] Recovery Step 1: Handling missing category...');
                  recoveryAttempted = true;
                  
                  // 1. Query for available expense categories
                  final queryCategoriesCall = AIToolCall(id: _uuid.v4(), name: 'query_categories', arguments: {'query_type': 'expense'});
                  final categoriesResult = await _toolRegistry.executeTool(queryCategoriesCall);

                  var validCategoryId = 1; // Default fallback
                  
                  if (categoriesResult.success && (categoriesResult.result as Map<String, dynamic>)['success'] == true) {
                    final categories = (categoriesResult.result as Map<String, dynamic>)['categories'] as List?;
                    if (categories != null && categories.isNotEmpty) {
                      final firstCategory = categories.first as Map<String, dynamic>;
                      validCategoryId = firstCategory['id'] as int? ?? 1;
                      debugPrint('[RealGeminiAI] Found existing expense category ID: $validCategoryId');
                    } else {
                      debugPrint('[RealGeminiAI] No expense categories found. Creating default category...');
                      
                      // 2. Create default expense category
                      try {
                        final createCategoryCall = AIToolCall(
                          id: _uuid.v4(), 
                          name: 'create_category', 
                          arguments: {
                            'name': 'Food & Dining',
                            'description': 'Meals, snacks, and dining expenses',
                            'is_expense': true,
                            'color': '#FF5722',
                            'icon': 'restaurant'
                          }
                        );
                        final createCategoryResult = await _toolRegistry.executeTool(createCategoryCall);
                        
                        if (createCategoryResult.success && (createCategoryResult.result as Map<String, dynamic>)['success'] == true) {
                          final newCategory = (createCategoryResult.result as Map<String, dynamic>)['category'] as Map<String, dynamic>?;
                          validCategoryId = newCategory?['id'] as int? ?? 1;
                          autoCreatedItems.add('default Food & Dining category');
                          debugPrint('[RealGeminiAI] Successfully created default category with ID: $validCategoryId');
                        } else {
                          debugPrint('[RealGeminiAI] Failed to create default category. Using fallback.');
                        }
                      } catch (e) {
                        debugPrint('[RealGeminiAI] Exception creating default category: $e');
                      }
                    }
                  }
                  
                  // Update the tool call with valid category ID
                  final newArgs = Map<String, dynamic>.from(toolCall.arguments);
                  newArgs['category_id'] = validCategoryId;
                  
                  // Check if account also needs fixing
                  if (error.contains('Account with ID') && error.contains('does not exist')) {
                    debugPrint('[RealGeminiAI] Recovery Step 2: Also handling missing account...');
                    
                    // Query for available accounts
                    final queryAccountsCall = AIToolCall(id: _uuid.v4(), name: 'query_accounts', arguments: {'query_type': 'all'});
                    final accountsResult = await _toolRegistry.executeTool(queryAccountsCall);
                    
                    var validAccountId = 1; // Default fallback
                    
                    if (accountsResult.success && (accountsResult.result as Map<String, dynamic>)['success'] == true) {
                      final accounts = (accountsResult.result as Map<String, dynamic>)['accounts'] as List?;
                      if (accounts != null && accounts.isNotEmpty) {
                        final firstAccount = accounts.first as Map<String, dynamic>;
                        validAccountId = firstAccount['id'] as int? ?? 1;
                        debugPrint('[RealGeminiAI] Found existing account ID: $validAccountId');
                      } else {
                        debugPrint('[RealGeminiAI] No accounts found. Creating default account...');
                        
                        try {
                          final createAccountCall = AIToolCall(
                            id: _uuid.v4(), 
                            name: 'create_account', 
                            arguments: {
                              'name': 'Main Account',
                              'account_type': 'cash',
                              'balance': 0.0,
                              'currency': 'VND'
                            }
                          );
                          final createAccountResult = await _toolRegistry.executeTool(createAccountCall);
                          
                          if (createAccountResult.success && (createAccountResult.result as Map<String, dynamic>)['success'] == true) {
                            final newAccount = (createAccountResult.result as Map<String, dynamic>)['account'] as Map<String, dynamic>?;
                            validAccountId = newAccount?['id'] as int? ?? 1;
                            autoCreatedItems.add('default Main Account');
                            debugPrint('[RealGeminiAI] Successfully created default account with ID: $validAccountId');
                          }
                        } catch (e) {
                          debugPrint('[RealGeminiAI] Exception creating default account: $e');
                        }
                      }
                    }
                    
                    newArgs['account_id'] = validAccountId;
                  }
                  
                  // 3. Retry create_transaction with fixed IDs
                  debugPrint('[RealGeminiAI] Recovery Step 3: Retrying create_transaction with valid IDs...');
                  final retryToolCall = toolCall.copyWith(arguments: newArgs);
                  toolResult = await _toolRegistry.executeTool(retryToolCall);
                  
                  debugPrint('[RealGeminiAI] Recovery attempt finished. Final result success: ${toolResult.success}');
                  final retryResultData = toolResult.result as Map<String, dynamic>;
                  debugPrint('[RealGeminiAI] Final transaction success: ${retryResultData['success']}');
                  
                  // If still failing due to account, try account recovery
                  if (retryResultData['success'] == false) {
                    final retryError = retryResultData['error'] as String?;
                    if (retryError != null && retryError.contains('Account with ID') && retryError.contains('does not exist')) {
                      debugPrint('[RealGeminiAI] Recovery Step 4: Now handling missing account...');
                      
                      // Query for available accounts
                      final queryAccountsCall = AIToolCall(id: _uuid.v4(), name: 'query_accounts', arguments: {'query_type': 'all'});
                      final accountsResult = await _toolRegistry.executeTool(queryAccountsCall);
                      
                      var validAccountId = 1; // Default fallback
                      
                      if (accountsResult.success && (accountsResult.result as Map<String, dynamic>)['success'] == true) {
                        final accounts = (accountsResult.result as Map<String, dynamic>)['accounts'] as List?;
                        if (accounts != null && accounts.isNotEmpty) {
                          final firstAccount = accounts.first as Map<String, dynamic>;
                          validAccountId = firstAccount['id'] as int? ?? 1;
                          debugPrint('[RealGeminiAI] Found existing account ID: $validAccountId');
                        } else {
                          debugPrint('[RealGeminiAI] No accounts found. Creating default account...');
                          
                          try {
                            final createAccountCall = AIToolCall(
                              id: _uuid.v4(), 
                              name: 'create_account', 
                              arguments: {
                                'name': 'Main Account',
                                'account_type': 'cash',
                                'balance': 0.0,
                                'currency': 'VND'
                              }
                            );
                            final createAccountResult = await _toolRegistry.executeTool(createAccountCall);
                            
                            if (createAccountResult.success && (createAccountResult.result as Map<String, dynamic>)['success'] == true) {
                              final newAccount = (createAccountResult.result as Map<String, dynamic>)['account'] as Map<String, dynamic>?;
                              validAccountId = newAccount?['id'] as int? ?? 1;
                              autoCreatedItems.add('default Main Account');
                              debugPrint('[RealGeminiAI] Successfully created default account with ID: $validAccountId');
                            } else {
                              debugPrint('[RealGeminiAI] Failed to create default account. Using fallback.');
                            }
                          } catch (e) {
                            debugPrint('[RealGeminiAI] Exception creating default account: $e');
                          }
                        }
                      }
                      
                      // Final retry with both category and account fixed
                      final finalArgs = Map<String, dynamic>.from(newArgs);
                      finalArgs['account_id'] = validAccountId;
                      
                      debugPrint('[RealGeminiAI] Recovery Step 5: Final retry with both category and account fixed...');
                      final finalRetryToolCall = toolCall.copyWith(arguments: finalArgs);
                      toolResult = await _toolRegistry.executeTool(finalRetryToolCall);
                      
                      final finalResultData = toolResult.result as Map<String, dynamic>;
                      debugPrint('[RealGeminiAI] Final retry result success: ${finalResultData['success']}');
                      
                      if (finalResultData['success'] == true && autoCreatedItems.isNotEmpty) {
                        finalResultData['auto_created_items'] = autoCreatedItems;
                        finalResultData['message'] = 'Transaction created successfully. I also set up ${autoCreatedItems.join(' and ')} for you.';
                        toolResult = toolResult.copyWith(result: finalResultData);
                      }
                    }
                  } else {
                    // Enhance the result with auto-creation info
                    if (retryResultData['success'] == true && autoCreatedItems.isNotEmpty) {
                      retryResultData['auto_created_items'] = autoCreatedItems;
                      retryResultData['message'] = 'Transaction created successfully. I also set up ${autoCreatedItems.join(' and ')} for you.';
                      toolResult = toolResult.copyWith(result: retryResultData);
                    }
                  }
                }
                
                // Handle missing account (when category is fine)
                else if (error.contains('Account with ID') && error.contains('does not exist')) {
                  debugPrint('[RealGeminiAI] Recovery: Handling missing account only...');
                  recoveryAttempted = true;
                  
                  // Query for available accounts
                  final queryAccountsCall = AIToolCall(id: _uuid.v4(), name: 'query_accounts', arguments: {'query_type': 'all'});
                  final accountsResult = await _toolRegistry.executeTool(queryAccountsCall);
                  
                  var validAccountId = 1; // Default fallback
                  
                  if (accountsResult.success && (accountsResult.result as Map<String, dynamic>)['success'] == true) {
                    final accounts = (accountsResult.result as Map<String, dynamic>)['accounts'] as List?;
                    if (accounts != null && accounts.isNotEmpty) {
                      final firstAccount = accounts.first as Map<String, dynamic>;
                      validAccountId = firstAccount['id'] as int? ?? 1;
                      debugPrint('[RealGeminiAI] Found existing account ID: $validAccountId');
                    } else {
                      debugPrint('[RealGeminiAI] No accounts found. Creating default account...');
                      
                      try {
                        final createAccountCall = AIToolCall(
                          id: _uuid.v4(), 
                          name: 'create_account', 
                          arguments: {
                            'name': 'Main Account',
                            'account_type': 'cash',
                            'balance': 0.0,
                            'currency': 'VND'
                          }
                        );
                        final createAccountResult = await _toolRegistry.executeTool(createAccountCall);
                        
                        if (createAccountResult.success && (createAccountResult.result as Map<String, dynamic>)['success'] == true) {
                          final newAccount = (createAccountResult.result as Map<String, dynamic>)['account'] as Map<String, dynamic>?;
                          validAccountId = newAccount?['id'] as int? ?? 1;
                          autoCreatedItems.add('default Main Account');
                          debugPrint('[RealGeminiAI] Successfully created default account with ID: $validAccountId');
                        } else {
                          debugPrint('[RealGeminiAI] Failed to create default account. Using fallback.');
                        }
                      } catch (e) {
                        debugPrint('[RealGeminiAI] Exception creating default account: $e');
                      }
                    }
                  }
                  
                  // Update the tool call with valid account ID
                  final newArgs = Map<String, dynamic>.from(toolCall.arguments);
                  newArgs['account_id'] = validAccountId;
                  
                  // Retry create_transaction with fixed account ID
                  debugPrint('[RealGeminiAI] Recovery: Retrying create_transaction with valid account ID...');
                  final retryToolCall = toolCall.copyWith(arguments: newArgs);
                  toolResult = await _toolRegistry.executeTool(retryToolCall);
                  
                  debugPrint('[RealGeminiAI] Account recovery attempt finished. Final result success: ${toolResult.success}');
                  final retryResultData = toolResult.result as Map<String, dynamic>;
                  debugPrint('[RealGeminiAI] Final transaction success: ${retryResultData['success']}');
                  
                  // Enhance the result with auto-creation info
                  if (retryResultData['success'] == true && autoCreatedItems.isNotEmpty) {
                    retryResultData['auto_created_items'] = autoCreatedItems;
                    retryResultData['message'] = 'Transaction created successfully. I also set up ${autoCreatedItems.join(' and ')} for you.';
                    toolResult = toolResult.copyWith(result: retryResultData);
                  }
                }
              }
              
              if (!recoveryAttempted) {
                debugPrint('[RealGeminiAI] No specific recovery pattern matched for error: $error');
              }
            }
            // --- END ENHANCED RETRY LOGIC ---
            
            if (toolResult.success) {
              final resultString = jsonEncode(toolResult.result);
              final previewLength = resultString.length > 200 ? 200 : resultString.length;
              debugPrint('[RealGeminiAI] Tool result: ${resultString.substring(0, previewLength)}${resultString.length > 200 ? '...' : ''}');
            } else {
              debugPrint('[RealGeminiAI] Tool error: ${toolResult.error}');
            }
            
            // Store tool result for potential formatting later
            debugPrint('[RealGeminiAI] Storing tool result for potential formatting');
            final updatedToolCall = toolCall.copyWith(
              result: jsonEncode(toolResult.result),
              isExecuted: true,
              error: toolResult.success ? null : toolResult.error,
            );
            
            // Replace the tool call in the list
            final index = toolCalls.indexOf(toolCall);
            if (index >= 0) {
              toolCalls[index] = updatedToolCall;
            }

            // Send tool result back to Gemini for response generation
            debugPrint('[RealGeminiAI] Sending tool result back to Gemini...');
            final geminiResponse = await _chatSession!.sendMessage(Content.functionResponse(
              functionCall.name,
              toolResult.success ? toolResult.result : {'error': toolResult.error},
            ));
            debugPrint('[RealGeminiAI] Tool result sent to Gemini successfully');
            
            // Debug what Gemini returned
            debugPrint('[RealGeminiAI] Gemini response text: ${geminiResponse.text}');
            debugPrint('[RealGeminiAI] Gemini response parts count: ${geminiResponse.candidates?.first.content.parts.length ?? 0}');
            
            // If Gemini provides a text response, add it to accumulated content
            if (geminiResponse.text != null && geminiResponse.text!.isNotEmpty) {
              accumulatedContent += geminiResponse.text!;
              debugPrint('[RealGeminiAI] Added Gemini response to content: ${geminiResponse.text!.length} chars');
            } else {
              debugPrint('[RealGeminiAI] WARNING: Gemini did not provide a text response after tool execution');
              // If Gemini doesn't provide a response, format the tool result ourselves
              final formattedResult = _formatToolResponse(message, toolCall, toolResult);
              accumulatedContent += formattedResult;
              debugPrint('[RealGeminiAI] Added formatted tool response: ${formattedResult.length} chars');
            }
          }

          // Yield response with tool execution
          yield AIResponse(
            id: responseId,
            content: 'Let me get that information for you...',
            toolCalls: toolCalls,
            isStreaming: true,
            isComplete: false,
            timestamp: DateTime.now(),
          );
          debugPrint('[RealGeminiAI] Yielded intermediate response with tool execution');
        }

        // Handle text content
        if (chunk.text != null) {
          debugPrint('[RealGeminiAI] Raw LLM text chunk: ${chunk.text}');
          accumulatedContent += chunk.text!;
          debugPrint('[RealGeminiAI] Accumulated content length: ${accumulatedContent.length}');
          
          yield AIResponse(
            id: responseId,
            content: accumulatedContent,
            toolCalls: toolCalls,
            isStreaming: true,
            isComplete: false,
            timestamp: DateTime.now(),
            metadata: {
              'model': _config?.model ?? 'gemini-1.5-pro',
              'has_tool_calls': hasToolCalls,
              'chunk_count': chunkCount,
            },
          );
          debugPrint('[RealGeminiAI] Yielded streaming response chunk #$chunkCount');
        }
      }

      debugPrint('[RealGeminiAI] Streaming completed. Total chunks: $chunkCount');
      debugPrint('[RealGeminiAI] Final content length: ${accumulatedContent.length}');
      debugPrint('[RealGeminiAI] Tool calls executed: ${toolCalls.length}');
      debugPrint('[RealGeminiAI] Accumulated content preview: ${accumulatedContent.length > 100 ? accumulatedContent.substring(0, 100) + '...' : accumulatedContent}');
      
      // Debug: Log complete raw response as JSON
      try {
        final responseData = {
          'total_chunks': chunkCount,
          'final_content': accumulatedContent,
          'tool_calls': toolCalls.map((tc) => {
            'id': tc.id,
            'name': tc.name,
            'arguments': tc.arguments,
            'result': tc.result,
            'isExecuted': tc.isExecuted,
            'error': tc.error,
          }).toList(),
          'has_tool_calls': hasToolCalls,
          'response_id': responseId,
        };
        debugPrint('[RealGeminiAI] RAW_RESPONSE_JSON: ${jsonEncode(responseData)}');
      } catch (e) {
        debugPrint('[RealGeminiAI] Error logging raw response JSON: $e');
      }

      // Final response - format tool results if no text content
      String finalContent = accumulatedContent;
      if (finalContent.isEmpty && toolCalls.isNotEmpty) {
        // Format tool results since Gemini didn't provide text
        debugPrint('[RealGeminiAI] No accumulated content, formatting tool results...');
        finalContent = _formatMultipleToolResults(toolCalls);
        debugPrint('[RealGeminiAI] Generated formatted content from tool results: ${finalContent.length} chars');
      } else if (finalContent.isEmpty) {
        finalContent = 'I have completed your request.';
        debugPrint('[RealGeminiAI] Using fallback message');
      } else {
        debugPrint('[RealGeminiAI] Using accumulated content as final response');
      }

      yield AIResponse(
        id: responseId,
        content: finalContent,
        toolCalls: toolCalls,
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {
          'model': _config?.model ?? 'gemini-1.5-pro',
          'has_tool_calls': hasToolCalls,
          'tool_count': toolCalls.length,
          'total_chunks': chunkCount,
        },
      );
      debugPrint('[RealGeminiAI] Final response yielded successfully');
      
    } catch (e) {
      debugPrint('[RealGeminiAI] ERROR in sendMessageStream: $e');
      debugPrint('[RealGeminiAI] Error type: ${e.runtimeType}');
      
      yield AIResponse(
        id: _uuid.v4(),
        content: AIErrorHandler.handleError(e),
        toolCalls: [],
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      );
      debugPrint('[RealGeminiAI] Error response yielded');
    }
  }

  @override
  Future<AIResponse> sendMessage(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  }) async {
    debugPrint('[RealGeminiAI] sendMessage called');
    debugPrint('[RealGeminiAI] User message: "$message"');
    
    if (!isInitialized || _model == null) {
      debugPrint('[RealGeminiAI] ERROR: AI service not initialized or model null');
      throw StateError('AI service not initialized');
    }

    try {
      // Apply rate limiting
      debugPrint('[RealGeminiAI] Checking rate limit...');
      await AIErrorHandler.checkRateLimit('sendMessage');
      debugPrint('[RealGeminiAI] Rate limit check passed');
      
      final responseId = _uuid.v4();
      debugPrint('[RealGeminiAI] Generated response ID: $responseId');
      
      // Send message to Gemini with retry logic
      debugPrint('[RealGeminiAI] Sending message to Gemini API...');
      final response = await AIErrorHandler.executeWithRetry(() async {
        debugPrint('[RealGeminiAI] Executing API call (with retry logic)');
        return _model!.generateContent([Content.text(message)]);
      });
      debugPrint('[RealGeminiAI] Gemini API call completed successfully');

      final toolCalls = <AIToolCall>[];
      // Collect all pieces of content to avoid overwriting when multiple tool
      // calls are executed. We will join these parts at the end.
      final List<String> _contentParts = [];

      // Debug: Print raw LLM response text
      debugPrint('[RealGeminiAI] Raw LLM response text: ${response.text}');

      // Handle function calls
      if (response.functionCalls.isNotEmpty) {
        debugPrint('[RealGeminiAI] Function calls detected: ${response.functionCalls.length}');
        
        final functionCallsList = response.functionCalls.toList();
        for (int i = 0; i < functionCallsList.length; i++) {
          final functionCall = functionCallsList[i];
          debugPrint('[RealGeminiAI] Processing function call ${i + 1}/${functionCallsList.length}: ${functionCall.name}');
          debugPrint('[RealGeminiAI] Function arguments: ${jsonEncode(functionCall.args)}');
        
          final toolCall = AIToolCall(
            id: _uuid.v4(),
            name: functionCall.name,
            arguments: functionCall.args,
          );
          toolCalls.add(toolCall);

          // Execute the tool
          debugPrint('[RealGeminiAI] Executing tool: ${toolCall.name}');
          var toolResult = await _toolRegistry.executeTool(toolCall);
          debugPrint('[RealGeminiAI] Tool execution result - Success: ${toolResult.success}');

                      // --- BEGIN ENHANCED RETRY LOGIC for create_transaction ---
            if (toolCall.name == 'create_transaction' &&
                toolResult.success &&
                (toolResult.result as Map<String, dynamic>)['success'] == false) {
              
              final error = (toolResult.result as Map<String, dynamic>)['error'] as String?;
              var recoveryAttempted = false;
              var autoCreatedItems = <String>[];
              
              if (error != null) {
                debugPrint('[RealGeminiAI] create_transaction failed: $error. Attempting comprehensive recovery...');
                
                // Handle missing category
                if (error.contains('Category with ID') && error.contains('does not exist')) {
                  debugPrint('[RealGeminiAI] Recovery Step 1: Handling missing category...');
                  recoveryAttempted = true;
                  
                  // 1. Query for available expense categories
                  final queryCategoriesCall = AIToolCall(id: _uuid.v4(), name: 'query_categories', arguments: {'query_type': 'expense'});
                  final categoriesResult = await _toolRegistry.executeTool(queryCategoriesCall);

                  var validCategoryId = 1; // Default fallback
                  
                  if (categoriesResult.success && (categoriesResult.result as Map<String, dynamic>)['success'] == true) {
                    final categories = (categoriesResult.result as Map<String, dynamic>)['categories'] as List?;
                    if (categories != null && categories.isNotEmpty) {
                      final firstCategory = categories.first as Map<String, dynamic>;
                      validCategoryId = firstCategory['id'] as int? ?? 1;
                      debugPrint('[RealGeminiAI] Found existing expense category ID: $validCategoryId');
                    } else {
                      debugPrint('[RealGeminiAI] No expense categories found. Creating default category...');
                      
                      // 2. Create default expense category
                      try {
                        final createCategoryCall = AIToolCall(
                          id: _uuid.v4(), 
                          name: 'create_category', 
                          arguments: {
                            'name': 'Food & Dining',
                            'description': 'Meals, snacks, and dining expenses',
                            'is_expense': true,
                            'color': '#FF5722',
                            'icon': 'restaurant'
                          }
                        );
                        final createCategoryResult = await _toolRegistry.executeTool(createCategoryCall);
                        
                        if (createCategoryResult.success && (createCategoryResult.result as Map<String, dynamic>)['success'] == true) {
                          final newCategory = (createCategoryResult.result as Map<String, dynamic>)['category'] as Map<String, dynamic>?;
                          validCategoryId = newCategory?['id'] as int? ?? 1;
                          autoCreatedItems.add('default Food & Dining category');
                          debugPrint('[RealGeminiAI] Successfully created default category with ID: $validCategoryId');
                        } else {
                          debugPrint('[RealGeminiAI] Failed to create default category. Using fallback.');
                        }
                      } catch (e) {
                        debugPrint('[RealGeminiAI] Exception creating default category: $e');
                      }
                    }
                  }
                  
                  // Update the tool call with valid category ID
                  final newArgs = Map<String, dynamic>.from(toolCall.arguments);
                  newArgs['category_id'] = validCategoryId;
                  
                  // 3. Retry create_transaction with fixed ID
                  debugPrint('[RealGeminiAI] Recovery Step 2: Retrying create_transaction with valid category ID...');
                  final retryToolCall = toolCall.copyWith(arguments: newArgs);
                  toolResult = await _toolRegistry.executeTool(retryToolCall);
                  
                  debugPrint('[RealGeminiAI] Recovery attempt finished. Final result success: ${toolResult.success}');
                  final retryResultData = toolResult.result as Map<String, dynamic>;
                  debugPrint('[RealGeminiAI] Final transaction success: ${retryResultData['success']}');
                  
                  // Enhance the result with auto-creation info
                  if (retryResultData['success'] == true && autoCreatedItems.isNotEmpty) {
                    retryResultData['auto_created_items'] = autoCreatedItems;
                    retryResultData['message'] = 'Transaction created successfully. I also set up ${autoCreatedItems.join(' and ')} for you.';
                    toolResult = toolResult.copyWith(result: retryResultData);
                  }
                }
                
                // Handle missing account (when category is fine)
                else if (error.contains('Account with ID') && error.contains('does not exist')) {
                  debugPrint('[RealGeminiAI] Recovery: Handling missing account only...');
                  recoveryAttempted = true;
                  
                  // Query for available accounts
                  final queryAccountsCall = AIToolCall(id: _uuid.v4(), name: 'query_accounts', arguments: {'query_type': 'all'});
                  final accountsResult = await _toolRegistry.executeTool(queryAccountsCall);
                  
                  var validAccountId = 1; // Default fallback
                  
                  if (accountsResult.success && (accountsResult.result as Map<String, dynamic>)['success'] == true) {
                    final accounts = (accountsResult.result as Map<String, dynamic>)['accounts'] as List?;
                    if (accounts != null && accounts.isNotEmpty) {
                      final firstAccount = accounts.first as Map<String, dynamic>;
                      validAccountId = firstAccount['id'] as int? ?? 1;
                      debugPrint('[RealGeminiAI] Found existing account ID: $validAccountId');
                    } else {
                      debugPrint('[RealGeminiAI] No accounts found. Creating default account...');
                      
                      try {
                        final createAccountCall = AIToolCall(
                          id: _uuid.v4(), 
                          name: 'create_account', 
                          arguments: {
                            'name': 'Main Account',
                            'account_type': 'cash',
                            'balance': 0.0,
                            'currency': 'VND'
                          }
                        );
                        final createAccountResult = await _toolRegistry.executeTool(createAccountCall);
                        
                        if (createAccountResult.success && (createAccountResult.result as Map<String, dynamic>)['success'] == true) {
                          final newAccount = (createAccountResult.result as Map<String, dynamic>)['account'] as Map<String, dynamic>?;
                          validAccountId = newAccount?['id'] as int? ?? 1;
                          autoCreatedItems.add('default Main Account');
                          debugPrint('[RealGeminiAI] Successfully created default account with ID: $validAccountId');
                        } else {
                          debugPrint('[RealGeminiAI] Failed to create default account. Using fallback.');
                        }
                      } catch (e) {
                        debugPrint('[RealGeminiAI] Exception creating default account: $e');
                      }
                    }
                  }
                  
                  // Update the tool call with valid account ID
                  final newArgs = Map<String, dynamic>.from(toolCall.arguments);
                  newArgs['account_id'] = validAccountId;
                  
                  // Retry create_transaction with fixed account ID
                  debugPrint('[RealGeminiAI] Recovery: Retrying create_transaction with valid account ID...');
                  final retryToolCall = toolCall.copyWith(arguments: newArgs);
                  toolResult = await _toolRegistry.executeTool(retryToolCall);
                  
                  debugPrint('[RealGeminiAI] Account recovery attempt finished. Final result success: ${toolResult.success}');
                  final retryResultData = toolResult.result as Map<String, dynamic>;
                  debugPrint('[RealGeminiAI] Final transaction success: ${retryResultData['success']}');
                  
                  // Enhance the result with auto-creation info
                  if (retryResultData['success'] == true && autoCreatedItems.isNotEmpty) {
                    retryResultData['auto_created_items'] = autoCreatedItems;
                    retryResultData['message'] = 'Transaction created successfully. I also set up ${autoCreatedItems.join(' and ')} for you.';
                    toolResult = toolResult.copyWith(result: retryResultData);
                  }
                }
              }
              
              if (!recoveryAttempted) {
                debugPrint('[RealGeminiAI] No specific recovery pattern matched for error: $error');
              }
            }
            // --- END ENHANCED RETRY LOGIC ---
          
          if (toolResult.success) {
            final resultString = jsonEncode(toolResult.result);
            final previewLength = resultString.length > 200 ? 200 : resultString.length;
            debugPrint('[RealGeminiAI] Tool result: ${resultString.substring(0, previewLength)}${resultString.length > 200 ? '...' : ''}');
          } else {
            debugPrint('[RealGeminiAI] Tool error: ${toolResult.error}');
          }
          
          // Format the response and add it to the list so that previous
          // results are preserved and not overwritten.
          final formatted = _formatToolResponse(message, toolCall, toolResult);
          _contentParts.add(formatted);
          debugPrint('[RealGeminiAI] Added formatted tool response (${formatted.length} chars)');
        }
      }

      // If Gemini also returned direct text, append it after tool responses
      if (response.text != null && response.text!.isNotEmpty) {
        _contentParts.add(response.text!);
        debugPrint('[RealGeminiAI] Added direct text response (${response.text!.length} chars)');
      }

      final content = _contentParts.join('\n\n').trim();

      // Debug: Log complete raw response as JSON
      try {
        final responseData = {
          'content': content,
          'tool_calls': toolCalls.map((tc) => {
            'id': tc.id,
            'name': tc.name,
            'arguments': tc.arguments,
            'result': tc.result,
            'isExecuted': tc.isExecuted,
            'error': tc.error,
          }).toList(),
          'response_id': responseId,
          'gemini_text': response.text,
          'gemini_function_calls': response.functionCalls.map((fc) => {
            'name': fc.name,
            'args': fc.args,
          }).toList(),
        };
        debugPrint('[RealGeminiAI] RAW_RESPONSE_JSON: ${jsonEncode(responseData)}');
      } catch (e) {
        debugPrint('[RealGeminiAI] Error logging raw response JSON: $e');
      }

      debugPrint('[RealGeminiAI] sendMessage completed successfully');
      return AIResponse(
        id: responseId,
        content: content,
        toolCalls: toolCalls,
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {
          'model': _config?.model ?? 'gemini-1.5-pro',
          'response_type': toolCalls.isNotEmpty ? 'tool_call' : 'direct',
          'tool_count': toolCalls.length,
        },
      );
      
    } catch (e) {
      debugPrint('[RealGeminiAI] ERROR in sendMessage: $e');
      debugPrint('[RealGeminiAI] Error type: ${e.runtimeType}');
      
      return AIResponse(
        id: _uuid.v4(),
        content: AIErrorHandler.handleError(e),
        toolCalls: [],
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> updateConfiguration(AIServiceConfig config) async {
    debugPrint('[RealGeminiAI] updateConfiguration called');
    await dispose();
    await initialize(config);
  }

  @override
  Future<void> dispose() async {
    debugPrint('[RealGeminiAI] dispose called');
    _isInitialized = false;
    _config = null;
    _model = null;
    _chatSession = null;
    debugPrint('[RealGeminiAI] disposed successfully');
  }

  /// Build Gemini function tools from available database tools
  List<Tool> _buildGeminiTools() {
    debugPrint('[RealGeminiAI] Building Gemini tools from available database tools...');
    final tools = <Tool>[];
    final availableTools = _toolRegistry.availableTools;
    debugPrint('[RealGeminiAI] Available tools count: ${availableTools.length}');
    
    for (int i = 0; i < availableTools.length; i++) {
      final toolConfig = availableTools[i];
      debugPrint('[RealGeminiAI] Building tool ${i + 1}/${availableTools.length}: ${toolConfig.name}');
      
      final functionDeclaration = FunctionDeclaration(
        toolConfig.name,
        toolConfig.description,
        Schema.object(
          properties: _convertSchemaProperties(toolConfig.schema['properties'] as Map<String, dynamic>? ?? {}),
          requiredProperties: (toolConfig.schema['required'] as List<dynamic>?)?.cast<String>() ?? [],
          description: toolConfig.description,
        ),
      );
      
      tools.add(Tool(functionDeclarations: [functionDeclaration]));
      debugPrint('[RealGeminiAI] Tool built: ${toolConfig.name}');
    }
    
    debugPrint('[RealGeminiAI] Total Gemini tools built: ${tools.length}');
    return tools;
  }

  /// Convert JSON schema properties to Gemini Schema properties
  Map<String, Schema> _convertSchemaProperties(Map<String, dynamic> properties) {
    final converted = <String, Schema>{};
    
    properties.forEach((key, value) {
      final prop = value as Map<String, dynamic>;
      final type = prop['type'] as String?;
      
      switch (type) {
        case 'string':
          if (prop['enum'] != null) {
            converted[key] = Schema.enumString(
              description: prop['description'] as String?,
              enumValues: (prop['enum'] as List).cast<String>(),
            );
          } else {
            converted[key] = Schema.string(
              description: prop['description'] as String?,
            );
          }
          break;
        case 'number':
          converted[key] = Schema.number(
            description: prop['description'] as String?,
          );
          break;
        case 'integer':
          converted[key] = Schema.integer(
            description: prop['description'] as String?,
          );
          break;
        case 'boolean':
          converted[key] = Schema.boolean(
            description: prop['description'] as String?,
          );
          break;
        case 'array':
          converted[key] = Schema.array(
            description: prop['description'] as String?,
            items: Schema.string(), // Simplified - could be more complex
          );
          break;
        case 'object':
          converted[key] = Schema.object(
            properties: <String, Schema>{},
            description: prop['description'] as String?,
          );
          break;
        default:
          converted[key] = Schema.string(
            description: prop['description'] as String?,
          );
      }
    });
    
    return converted;
  }

  /// Build comprehensive system prompt for financial assistant
  String _buildSystemPrompt() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd'); // Using a simple format for now
    final currentDate = formatter.format(now);

    return '''
You are an AI Financial Assistant for a personal finance management app. You have access to comprehensive financial tools and data.
The current date is $currentDate.

**Your Role:**
- Help users understand their financial situation
- Provide insights and recommendations
- Execute financial operations through available tools
- Maintain a professional, helpful, and encouraging tone

**Your Capabilities:**
- Query and analyze transactions, budgets, accounts, and categories
- Create, update, and delete financial records
- Provide financial insights and recommendations
- Calculate budgets, spending patterns, and trends
- Help with financial planning and goal setting

**Language Support:**
- Support both English and Vietnamese language interactions
- Understand financial terms and expressions in both languages
- Recognize transaction creation requests in natural language

**CRITICAL: Transaction Creation Recognition**
When users mention spending money or making purchases, you MUST ALWAYS use the create_transaction tool. DO NOT just respond with text saying you've recorded it - you MUST actually call the tool.

English Examples (MUST CREATE transaction via tool):
- "I bought coffee for \$5"
- "Spent \$20 on gas" 
- "Just ate lunch for \$15"
- "Paid \$100 for groceries"

Vietnamese Examples (MUST CREATE transaction via tool):
- "mới đi ăn phở 35k" → MUST CALL create_transaction: title="Ăn phở", amount=-35000
- "vừa mua cafe 25k" → MUST CALL create_transaction: title="Mua cafe", amount=-25000
- "chi tiền ăn uống 50k" → MUST CALL create_transaction: title="Ăn uống", amount=-50000
- "đi ăn trưa 40k" → MUST CALL create_transaction: title="Ăn trưa", amount=-40000

Keywords that REQUIRE create_transaction tool call:
- English: bought, spent, paid, purchased, ate, went
- Vietnamese: mới, vừa, chi tiền, đi ăn, mua, ăn

NEVER just say you've recorded a transaction - you MUST use the create_transaction tool to actually record it.

Only use query_transactions when users want to VIEW existing transactions:
- "Show me my transactions"
- "Xem giao dịch của tôi"
- "Find transactions"
- "Tìm giao dịch"

**Transaction Creation Process:**
MANDATORY: When ANY transaction creation keyword is detected (mới, vừa, đi ăn, mua, bought, spent, paid, etc.), you MUST call the create_transaction tool. Do NOT respond with text only.

1. ALWAYS use the `create_transaction` tool when a user expresses intent to record spending or income.
2. Extract `amount` (convert k=1000, e.g., 35k = 35000).
3. Extract `title` from context (e.g., "ăn phở" = "Ăn phở").
4. Use negative amount for expenses.
5. For `account_id` and `category_id`:
   - **MUST** provide these. Use the following smart approach:
     - `account_id`: Query for available accounts first using `query_accounts` tool to get a valid account ID. If you need to save time, you can use a reasonable guess like `1` for the first account, but the system has auto-recovery if the ID doesn't exist.
     - `category_id`: For expense categories, use these smart defaults:
       * Food/restaurant expenses (phở, cafe, ăn, uống, lunch, dinner, coffee, restaurant): Query categories using `query_categories` tool to find food-related categories first.
       * For other expenses: Query for appropriate expense categories.
       * You can use reasonable guesses like `1` if needed - the system has auto-recovery that will find valid IDs or create defaults if none exist.
6. Set `date` to today if not specified.

7. **IMPORTANT: Don't worry about exact IDs - the system has intelligent auto-recovery that will automatically:**
   - Find valid account/category IDs if your guess is wrong
   - Create default accounts/categories if none exist
   - Retry the transaction with correct IDs
   - Inform you about any auto-created defaults

**EXAMPLE FUNCTION CALL (Vietnamese):**
```json
{
  "name": "create_transaction",
  "arguments": {
    "title": "Ăn phở",
    "amount": -35000,
    "category_id": 1,
    "account_id": 1,
    "note": "Đi ăn phở"
  }
}
```
*Note: The system will auto-correct any invalid IDs and create defaults if needed.*

**EXAMPLE FUNCTION CALL (English):**
```json
{
  "name": "create_transaction",
  "arguments": {
    "title": "Bought coffee",
    "amount": -5000,
    "category_id": 1,
    "account_id": 1,
    "note": "Morning coffee"
  }
}
```
*Note: The system will auto-correct any invalid IDs and create defaults if needed.*

When making a function call, respond **only** with the function call (no extra text, no markdown fences) so the system can detect and execute it.

**IMPORTANT**: The system is self-healing! If `create_transaction` fails due to invalid category_id or account_id, the system will automatically:
1. Query for existing categories/accounts
2. If none exist, create default ones (Food & Dining category, Main Account)
3. Retry the transaction creation with valid IDs
4. Inform you about any automatically created defaults

This means you can confidently create transactions even in a fresh/empty database - the system will set up everything needed automatically.

**Communication Style:**
- Be conversational but professional
- Use clear, easy-to-understand language
- Format financial data clearly (use bullet points, tables when appropriate)
- Provide actionable insights and suggestions
- Always ask clarifying questions when needed
- Be encouraging about financial goals and progress

**Financial Expertise:**
- Understand budgeting principles
- Recognize spending patterns and trends
- Suggest cost-saving opportunities
- Help with financial goal planning
- Provide context for financial decisions

**Tool Usage Guidelines:**
- MANDATORY: ALWAYS use create_transaction tool for ANY spending mentions (mới, vừa, chi, đi ăn, mua, bought, spent, paid, ate) - NEVER just say you've recorded it
- Use query_transactions ONLY for viewing/searching existing transactions
- Use query_categories to find available category IDs when needed
- Always use appropriate tools to access current user data
- Format responses with actual data, not assumptions
- Explain what you're doing when using tools
- Provide summaries and insights after retrieving data
- If a tool call fails, analyze the error and retry with corrected parameters

CRITICAL RULE: For transaction creation, tool calls are MANDATORY - text-only responses are NOT allowed.

**Data Presentation:**
- Use [TRANSACTIONS_DATA] tags for rich transaction displays in responses
- Show amounts with proper currency formatting
- Include relevant dates and timeframes
- Highlight important trends or alerts
- Use clear categorization and organization

Remember: You have access to the user's complete financial data through your tools. Always provide helpful, accurate, and personalized advice based on their actual financial situation.
''';
  }

  /// Format tool execution response for user presentation
  String _formatToolResponse(
    String originalMessage,
    AIToolCall toolCall,
    ToolExecutionResult toolResult,
  ) {
    if (!toolResult.success) {
      return 'I encountered an issue retrieving your ${toolCall.name.replaceAll('query_', '').replaceAll('_', ' ')}: ${toolResult.error ?? 'Unknown error'}';
    }

    final result = toolResult.result as Map<String, dynamic>?;
    if (result == null) {
      return 'I could not find any data for your request.';
    }

    switch (toolCall.name) {
      case 'create_transaction':
        return _formatCreateTransactionResponse(result);
      case 'query_transactions':
        return _formatTransactionResponse(result);
      case 'query_budgets':
        return _formatBudgetResponse(result);
      case 'query_accounts':
        return _formatAccountResponse(result);
      case 'query_categories':
        return _formatCategoryResponse(result);
      default:
        return 'I found some information about your ${toolCall.name.replaceAll('query_', '').replaceAll('_', ' ')}: ${jsonEncode(result)}';
    }
  }

  String _formatCreateTransactionResponse(Map<String, dynamic> result) {
    if (result['success'] == true) {
      final transaction = result['transaction'] as Map<String, dynamic>?;
      final autoCreatedItems = result['auto_created_items'] as List<String>?;
      final customMessage = result['message'] as String?;
      
      if (customMessage != null) {
        return customMessage; // Use the enhanced message with auto-creation info
      }
      
      if (transaction != null) {
        final amount = transaction['amount'] ?? 0.0;
        final title = transaction['title'] ?? 'Transaction';
        final formattedAmount = amount.abs().toStringAsFixed(0);
        
        String response = '✅ Successfully recorded your expense of ${formattedAmount} VND for "$title".';
        
        if (autoCreatedItems != null && autoCreatedItems.isNotEmpty) {
          response += '\n\n🎉 I also set up ${autoCreatedItems.join(' and ')} for you since this was your first transaction!';
        }
        
        return response;
      }
      
      return 'Transaction created successfully!';
    } else {
      final error = result['error'] as String?;
      final parameters = result['parameters'] as Map<String, dynamic>?;
      
      // Provide more helpful error messages
      if (error != null) {
        if (error.contains('Account with ID') && error.contains('does not exist')) {
          return 'I had trouble finding your account. The system will automatically create a default account for you. Please try your transaction again.';
        } else if (error.contains('Category with ID') && error.contains('does not exist')) {
          return 'I had trouble finding the right category. The system will automatically create appropriate categories for you. Please try your transaction again.';
        } else if (error.contains('FOREIGN KEY constraint failed')) {
          return 'There was a database constraint issue. The system has auto-recovery features that will fix this. Please try your transaction again.';
        }
      }
      
      String errorMessage = 'I encountered an issue creating your transaction';
      if (error != null) {
        errorMessage += ': $error';
      }
      if (parameters != null) {
        errorMessage += '\nParameters used: ${parameters.toString()}';
      }
      errorMessage += '. The system has auto-recovery features, so please try again.';
      
      return errorMessage;
    }
  }

  String _formatTransactionResponse(Map<String, dynamic> result) {
    final count = result['count'] ?? 0;
    final transactions = result['transactions'] as List? ?? [];
    
    if (count == 0) {
      return 'You do not have any transactions recorded yet. Would you like me to help you add some?';
    }
    
    // Create a rich formatted response with structured data for UI rendering
    String response = 'I found $count transaction${count == 1 ? '' : 's'} matching your search:\n\n';
    
    // Add structured transaction data that the UI can parse for rich display
    response += '[TRANSACTIONS_DATA]\n';
    response += jsonEncode(transactions.take(5).toList());
    response += '\n[/TRANSACTIONS_DATA]\n\n';
    
    // Add readable text summary
    for (int i = 0; i < transactions.take(3).length; i++) {
      final transaction = transactions[i] as Map<String, dynamic>;
      final amount = transaction['amount'] ?? 0.0;
      final description = transaction['description'] ?? 'Unknown';
      final date = transaction['date'] ?? 'Unknown date';
      
      response += '💰 ${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)} - $description ($date)\n';
    }
    
    if (transactions.length > 3) {
      response += '\n... and ${transactions.length - 3} more transaction${transactions.length - 3 == 1 ? '' : 's'}. Tap on any transaction above to view details.';
    } else if (transactions.isNotEmpty) {
      response += '\nTap on any transaction above to view details.';
    }
    
    return response;
  }

  String _formatBudgetResponse(Map<String, dynamic> result) {
    final count = result['count'] ?? 0;
    final budgets = result['budgets'] as List? ?? [];
    
    if (count == 0) {
      return 'You do not have any budgets set up yet. Would you like me to help you create one?';
    }
    
    String response = 'Here are your current budgets:\n\n';
    
    for (final budget in budgets.take(3)) {
      final budgetData = budget as Map<String, dynamic>;
      final amount = budgetData['amount'] ?? 0.0;
      final name = budgetData['name'] ?? 'Unnamed Budget';
      final spent = budgetData['spent'] ?? 0.0;
      final remaining = amount - spent;
      
      response += '• $name: ${spent.toStringAsFixed(2)} / ${amount.toStringAsFixed(2)} (${remaining.toStringAsFixed(2)} remaining)\n';
    }
    
    return response;
  }

  String _formatAccountResponse(Map<String, dynamic> result) {
    final count = result['count'] ?? 0;
    final accounts = result['accounts'] as List? ?? [];
    
    if (count == 0) {
      return 'You do not have any accounts set up yet. Would you like me to help you add one?';
    }
    
    String response = 'Here are your accounts:\n\n';
    double totalBalance = 0.0;
    
    for (final account in accounts) {
      final accountData = account as Map<String, dynamic>;
      final balance = accountData['balance'] ?? 0.0;
      final name = accountData['name'] ?? 'Unnamed Account';
      final currency = accountData['currency'] ?? 'USD';
      
      response += '• $name: ${balance.toStringAsFixed(2)} $currency\n';
      totalBalance += balance;
    }
    
    response += '\nTotal Balance: ${totalBalance.toStringAsFixed(2)}';
    
    return response;
  }

  String _formatCategoryResponse(Map<String, dynamic> result) {
    final count = result['count'] ?? 0;
    final categories = result['categories'] as List? ?? [];
    
    if (count == 0) {
      return 'You do not have any categories set up yet. The app will use default categories.';
    }
    
    final expenseCategories = categories.where((c) => 
      (c as Map<String, dynamic>)['is_expense'] == true
    ).length;
    final incomeCategories = count - expenseCategories;
    
    String response = 'You have $count categories set up:\n';
    response += '• $expenseCategories expense categories\n';
    response += '• $incomeCategories income categories\n\n';
    
    response += 'This helps you organize and track your financial transactions effectively!';
    
    return response;
  }

  /// Format multiple tool results when Gemini doesn't provide text response
  String _formatMultipleToolResults(List<AIToolCall> toolCalls) {
    if (toolCalls.isEmpty) return 'No data found.';
    
    final StringBuffer response = StringBuffer();
    
    for (final toolCall in toolCalls) {
      if (toolCall.result != null) {
        try {
          final resultData = jsonDecode(toolCall.result!);
          final formattedResult = _formatToolResultData(toolCall.name, resultData);
          response.writeln(formattedResult);
        } catch (e) {
          debugPrint('[RealGeminiAI] Error formatting tool result: $e');
          response.writeln(_formatToolCallFallback(toolCall));
        }
      } else {
        response.writeln(_formatToolCallFallback(toolCall));
      }
      
      if (toolCalls.length > 1) response.writeln();
    }
    
    return response.toString().trim();
  }

  /// Format tool result data using the same logic as existing formatters
  String _formatToolResultData(String toolName, dynamic resultData) {
    if (resultData is! Map<String, dynamic>) {
      return 'I retrieved the data but couldn\'t format it properly.';
    }

    final result = resultData;
    
    switch (toolName) {
      case 'create_transaction':
        return _formatCreateTransactionResponse(result);
      case 'query_transactions':
        return _formatTransactionResponse(result);
      case 'query_budgets':
        return _formatBudgetResponse(result);
      case 'query_accounts':
        return _formatAccountResponse(result);
      case 'query_categories':
        return _formatCategoryResponse(result);
      default:
        return 'I found some information about your ${toolName.replaceAll('query_', '').replaceAll('_', ' ')}: ${jsonEncode(result)}';
    }
  }

  /// Fallback formatting when tool result is not available
  String _formatToolCallFallback(AIToolCall toolCall) {
    switch (toolCall.name) {
      case 'query_transactions':
        if (toolCall.arguments['keyword'] != null) {
          return 'I searched for transactions containing "${toolCall.arguments['keyword']}" but couldn\'t retrieve the results properly. Please try asking again or check your transaction list directly.';
        }
        return 'I found your transactions but couldn\'t display them properly. Please try asking again.';
      case 'query_budgets':
        return 'I retrieved your budget information but couldn\'t display it properly. Please try asking again.';
      case 'query_accounts':
        return 'I found your account information but couldn\'t display it properly. Please try asking again.';
      case 'query_categories':
        return 'I retrieved your categories but couldn\'t display them properly. Please try asking again.';
      default:
        return 'I executed the requested operation but couldn\'t display the results properly. Please try asking again.';
    }
  }
} 