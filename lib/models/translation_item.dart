class TranslationItem {
  final String key;
  final String originalValue;
  String translatedValue;
  final JsonMetadata? metadata;
  final bool hasPlaceholders;
  final bool isCompleted;
  final DateTime? lastModified;
  final bool? isType;

  TranslationItem({
    required this.key,
    required this.originalValue,
    required this.translatedValue,
    this.metadata,
    required this.hasPlaceholders,
    this.isCompleted = false,
    this.lastModified,
    this.isType = false,
  });

  factory TranslationItem.fromJson(Map<String, dynamic> json) {
    return TranslationItem(
      key: json['key'] as String,
      originalValue: json['originalValue'] as String,
      translatedValue: json['translatedValue'] as String,
      metadata: json['metadata'] != null
          ? JsonMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      hasPlaceholders: json['hasPlaceholders'] as bool,
      isCompleted: json['isCompleted'] as bool? ?? false,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : null,
      isType: json['isType'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'originalValue': originalValue,
      'translatedValue': translatedValue,
      'metadata': metadata?.toJson(),
      'hasPlaceholders': hasPlaceholders,
      'isCompleted': isCompleted,
      'lastModified': lastModified?.toIso8601String(),
      'isType': isType,
    };
  }

  TranslationItem copyWith({
    String? key,
    String? originalValue,
    String? translatedValue,
    JsonMetadata? metadata,
    bool? hasPlaceholders,
    bool? isCompleted,
    DateTime? lastModified,
    bool? isType,
  }) {
    return TranslationItem(
      key: key ?? this.key,
      originalValue: originalValue ?? this.originalValue,
      translatedValue: translatedValue ?? this.translatedValue,
      metadata: metadata ?? this.metadata,
      hasPlaceholders: hasPlaceholders ?? this.hasPlaceholders,
      isCompleted: isCompleted ?? this.isCompleted,
      lastModified: lastModified ?? this.lastModified,
      isType: isType ?? this.isType,
    );
  }

  bool get isEmpty => translatedValue.trim().isEmpty;
  bool get isNotEmpty => translatedValue.trim().isNotEmpty;
}

class JsonMetadata {
  final Map<String, PlaceholderInfo>? placeholders;
  final String? description;
  final String? context;
  final String? type;

  JsonMetadata({this.placeholders, this.description, this.context, this.type});

  factory JsonMetadata.fromJson(Map<String, dynamic> json) {
    return JsonMetadata(
      placeholders: json['placeholders'] != null
          ? (json['placeholders'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                PlaceholderInfo.fromJson(value as Map<String, dynamic>),
              ),
            )
          : null,
      description: json['description'] as String?,
      context: json['context'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeholders': placeholders?.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'description': description,
      'context': context,
      'type': type,
    };
  }
}

class PlaceholderInfo {
  final String type;
  final String? description;
  final String? example;

  PlaceholderInfo({required this.type, this.description, this.example});

  factory PlaceholderInfo.fromJson(Map<String, dynamic> json) {
    return PlaceholderInfo(
      type: json['type'] as String,
      description: json['description'] as String?,
      example: json['example'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'description': description, 'example': example};
  }
}
