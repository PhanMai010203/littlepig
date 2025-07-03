class VoiceCommand {
  final String id;
  final String text;
  final String? originalAudio;
  final double confidence;
  final String language;
  final DateTime timestamp;
  final VoiceCommandStatus status;
  final Map<String, dynamic>? metadata;

  const VoiceCommand({
    required this.id,
    required this.text,
    this.originalAudio,
    required this.confidence,
    required this.language,
    required this.timestamp,
    this.status = VoiceCommandStatus.recognized,
    this.metadata,
  });

  VoiceCommand copyWith({
    String? id,
    String? text,
    String? originalAudio,
    double? confidence,
    String? language,
    DateTime? timestamp,
    VoiceCommandStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return VoiceCommand(
      id: id ?? this.id,
      text: text ?? this.text,
      originalAudio: originalAudio ?? this.originalAudio,
      confidence: confidence ?? this.confidence,
      language: language ?? this.language,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'originalAudio': originalAudio,
      'confidence': confidence,
      'language': language,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'metadata': metadata,
    };
  }

  factory VoiceCommand.fromJson(Map<String, dynamic> json) {
    return VoiceCommand(
      id: json['id'],
      text: json['text'],
      originalAudio: json['originalAudio'],
      confidence: json['confidence'],
      language: json['language'],
      timestamp: DateTime.parse(json['timestamp']),
      status: VoiceCommandStatus.values.byName(json['status']),
      metadata: json['metadata'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoiceCommand &&
        other.id == id &&
        other.text == text &&
        other.confidence == confidence &&
        other.language == language;
  }

  @override
  int get hashCode {
    return Object.hash(id, text, confidence, language);
  }

  @override
  String toString() {
    return 'VoiceCommand(id: $id, text: $text, confidence: $confidence, language: $language, status: $status)';
  }
}

enum VoiceCommandStatus {
  listening,
  recognized,
  processed,
  error,
  cancelled,
}

class VoiceResponse {
  final String id;
  final String text;
  final String? audioUrl;
  final double? speechRate;
  final double? pitch;
  final double? volume;
  final String language;
  final DateTime timestamp;
  final VoiceResponseStatus status;
  final Map<String, dynamic>? metadata;

  const VoiceResponse({
    required this.id,
    required this.text,
    this.audioUrl,
    this.speechRate,
    this.pitch,
    this.volume,
    required this.language,
    required this.timestamp,
    this.status = VoiceResponseStatus.ready,
    this.metadata,
  });

  VoiceResponse copyWith({
    String? id,
    String? text,
    String? audioUrl,
    double? speechRate,
    double? pitch,
    double? volume,
    String? language,
    DateTime? timestamp,
    VoiceResponseStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return VoiceResponse(
      id: id ?? this.id,
      text: text ?? this.text,
      audioUrl: audioUrl ?? this.audioUrl,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      language: language ?? this.language,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'audioUrl': audioUrl,
      'speechRate': speechRate,
      'pitch': pitch,
      'volume': volume,
      'language': language,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'metadata': metadata,
    };
  }

  factory VoiceResponse.fromJson(Map<String, dynamic> json) {
    return VoiceResponse(
      id: json['id'],
      text: json['text'],
      audioUrl: json['audioUrl'],
      speechRate: json['speechRate'],
      pitch: json['pitch'],
      volume: json['volume'],
      language: json['language'],
      timestamp: DateTime.parse(json['timestamp']),
      status: VoiceResponseStatus.values.byName(json['status']),
      metadata: json['metadata'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoiceResponse &&
        other.id == id &&
        other.text == text &&
        other.language == language;
  }

  @override
  int get hashCode {
    return Object.hash(id, text, language);
  }

  @override
  String toString() {
    return 'VoiceResponse(id: $id, text: $text, language: $language, status: $status)';
  }
}

enum VoiceResponseStatus {
  ready,
  speaking,
  completed,
  error,
  cancelled,
}

class VoiceSettings {
  final String language;
  final String? locale;
  final double speechRate;
  final double pitch;
  final double volume;
  final bool enableContinuousListening;
  final Duration listeningTimeout;
  final Duration pauseThreshold;
  final bool enablePartialResults;
  final bool enableHapticFeedback;
  final bool enableVisualFeedback;
  final List<String> preferredEngines;

  const VoiceSettings({
    this.language = 'auto',
    this.locale,
    this.speechRate = 0.8,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.enableContinuousListening = false,
    this.listeningTimeout = const Duration(seconds: 30),
    this.pauseThreshold = const Duration(seconds: 2),
    this.enablePartialResults = true,
    this.enableHapticFeedback = true,
    this.enableVisualFeedback = true,
    this.preferredEngines = const [],
  });

  VoiceSettings copyWith({
    String? language,
    String? locale,
    double? speechRate,
    double? pitch,
    double? volume,
    bool? enableContinuousListening,
    Duration? listeningTimeout,
    Duration? pauseThreshold,
    bool? enablePartialResults,
    bool? enableHapticFeedback,
    bool? enableVisualFeedback,
    List<String>? preferredEngines,
  }) {
    return VoiceSettings(
      language: language ?? this.language,
      locale: locale ?? this.locale,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      enableContinuousListening: enableContinuousListening ?? this.enableContinuousListening,
      listeningTimeout: listeningTimeout ?? this.listeningTimeout,
      pauseThreshold: pauseThreshold ?? this.pauseThreshold,
      enablePartialResults: enablePartialResults ?? this.enablePartialResults,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableVisualFeedback: enableVisualFeedback ?? this.enableVisualFeedback,
      preferredEngines: preferredEngines ?? this.preferredEngines,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'locale': locale,
      'speechRate': speechRate,
      'pitch': pitch,
      'volume': volume,
      'enableContinuousListening': enableContinuousListening,
      'listeningTimeout': listeningTimeout.inMilliseconds,
      'pauseThreshold': pauseThreshold.inMilliseconds,
      'enablePartialResults': enablePartialResults,
      'enableHapticFeedback': enableHapticFeedback,
      'enableVisualFeedback': enableVisualFeedback,
      'preferredEngines': preferredEngines,
    };
  }

  factory VoiceSettings.fromJson(Map<String, dynamic> json) {
    return VoiceSettings(
      language: json['language'] ?? 'en-US',
      locale: json['locale'],
      speechRate: json['speechRate'] ?? 0.8,
      pitch: json['pitch'] ?? 1.0,
      volume: json['volume'] ?? 1.0,
      enableContinuousListening: json['enableContinuousListening'] ?? false,
      listeningTimeout: Duration(milliseconds: json['listeningTimeout'] ?? 30000),
      pauseThreshold: Duration(milliseconds: json['pauseThreshold'] ?? 2000),
      enablePartialResults: json['enablePartialResults'] ?? true,
      enableHapticFeedback: json['enableHapticFeedback'] ?? true,
      enableVisualFeedback: json['enableVisualFeedback'] ?? true,
      preferredEngines: List<String>.from(json['preferredEngines'] ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoiceSettings &&
        other.language == language &&
        other.speechRate == speechRate &&
        other.pitch == pitch &&
        other.volume == volume;
  }

  @override
  int get hashCode {
    return Object.hash(language, speechRate, pitch, volume);
  }

  @override
  String toString() {
    return 'VoiceSettings(language: $language, speechRate: $speechRate, pitch: $pitch, volume: $volume)';
  }
} 