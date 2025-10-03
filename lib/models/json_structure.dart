import 'translation_item.dart';

class JsonStructure {
  final Map<String, dynamic> originalJson;
  final List<TranslationItem> translationItems;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime createdAt;
  final DateTime? lastModified;
  final String fileName;

  JsonStructure({
    required this.originalJson,
    required this.translationItems,
    this.sourceLanguage = 'en',
    this.targetLanguage = 'fa',
    required this.createdAt,
    this.lastModified,
    required this.fileName,
  });

  factory JsonStructure.fromJson(Map<String, dynamic> json) {
    return JsonStructure(
      originalJson: json['originalJson'] as Map<String, dynamic>,
      translationItems: (json['translationItems'] as List)
          .map((item) => TranslationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      sourceLanguage: json['sourceLanguage'] as String? ?? 'en',
      targetLanguage: json['targetLanguage'] as String? ?? 'fa',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: json['lastModified'] != null 
          ? DateTime.parse(json['lastModified'] as String) 
          : null,
      fileName: json['fileName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalJson': originalJson,
      'translationItems': translationItems.map((item) => item.toJson()).toList(),
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'fileName': fileName,
    };
  }

  JsonStructure copyWith({
    Map<String, dynamic>? originalJson,
    List<TranslationItem>? translationItems,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
    DateTime? lastModified,
    String? fileName,
  }) {
    return JsonStructure(
      originalJson: originalJson ?? this.originalJson,
      translationItems: translationItems ?? this.translationItems,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      fileName: fileName ?? this.fileName,
    );
  }

  int get totalItems => translationItems.length;
  int get completedItems => translationItems.where((item) => item.isCompleted).length;
  int get pendingItems => totalItems - completedItems;
  double get progressPercentage => totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;

  bool get isFullyTranslated => completedItems == totalItems;
  bool get hasTranslations => completedItems > 0;

  Map<String, dynamic> getTranslatedJson() {
    final Map<String, dynamic> result = Map.from(originalJson);
    
    for (final item in translationItems) {
      if (item.isCompleted && item.translatedValue.isNotEmpty) {
        _setNestedValue(result, item.key, item.translatedValue);
      }
    }
    
    return result;
  }

  void _setNestedValue(Map<String, dynamic> map, String key, dynamic value) {
    final keys = key.split('.');
    Map<String, dynamic> current = map;
    
    for (int i = 0; i < keys.length - 1; i++) {
      if (!current.containsKey(keys[i])) {
        current[keys[i]] = <String, dynamic>{};
      }
      current = current[keys[i]] as Map<String, dynamic>;
    }
    
    current[keys.last] = value;
  }
}
