import 'dart:convert';
import '../models/translation_item.dart';
import '../models/json_structure.dart';

class JsonParserService {
  static const String placeholderPattern = r'\{\{([^}]+)\}\}';
  static final RegExp placeholderRegex = RegExp(placeholderPattern);

  /// Parse JSON file and extract translatable strings
  static JsonStructure parseJsonFile({
    required String jsonContent,
    required String fileName,
    String sourceLanguage = 'en',
    String targetLanguage = 'fa',
  }) {
    try {
      final Map<String, dynamic> jsonData = json.decode(jsonContent);
      final List<TranslationItem> translationItems = [];
      
      _extractTranslatableStrings(
        jsonData,
        translationItems,
        '',
      );

      return JsonStructure(
        originalJson: jsonData,
        translationItems: translationItems,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        createdAt: DateTime.now(),
        fileName: fileName,
      );
    } catch (e) {
      throw JsonParserException('خطا در تجزیه فایل JSON: $e');
    }
  }

  /// Extract translatable strings from JSON recursively
  static void _extractTranslatableStrings(
    dynamic data,
    List<TranslationItem> items,
    String currentPath,
  ) {
    if (data is Map<String, dynamic>) {
      data.forEach((key, value) {
        final newPath = currentPath.isEmpty ? key : '$currentPath.$key';
        
        if (value is String) {
          // Check if this is a translatable string (not a metadata key)
          if (!key.startsWith('@')) {
            final hasPlaceholders = placeholderRegex.hasMatch(value);
            final metadata = _extractMetadata(data, key);
            
            items.add(TranslationItem(
              key: newPath,
              originalValue: value,
              translatedValue: '',
              metadata: metadata,
              hasPlaceholders: hasPlaceholders,
            ));
          }
        } else if (value is Map<String, dynamic>) {
          _extractTranslatableStrings(value, items, newPath);
        } else if (value is List) {
          _extractTranslatableStrings(value, items, newPath);
        }
      });
    } else if (data is List) {
      for (int i = 0; i < data.length; i++) {
        _extractTranslatableStrings(data[i], items, '$currentPath[$i]');
      }
    }
  }

  /// Extract metadata for a specific key
  static JsonMetadata? _extractMetadata(Map<String, dynamic> data, String key) {
    final metadataKey = '@$key';
    if (data.containsKey(metadataKey)) {
      final metadataData = data[metadataKey] as Map<String, dynamic>;
      
      Map<String, PlaceholderInfo>? placeholders;
      if (metadataData.containsKey('placeholders')) {
        placeholders = <String, PlaceholderInfo>{};
        final placeholdersData = metadataData['placeholders'] as Map<String, dynamic>;
        placeholdersData.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            placeholders![key] = PlaceholderInfo(
              type: value['type'] ?? 'String',
              description: value['description'],
              example: value['example'],
            );
          }
        });
      }

      return JsonMetadata(
        placeholders: placeholders,
        description: metadataData['description'],
        context: metadataData['context'],
        type: metadataData['type'],
      );
    }
    return null;
  }

  /// Extract placeholders from a string
  static List<String> extractPlaceholders(String text) {
    final matches = placeholderRegex.allMatches(text);
    return matches.map((match) => match.group(1)!).toList();
  }

  /// Validate that all placeholders are preserved in translation
  static bool validatePlaceholders(String original, String translated) {
    final originalPlaceholders = extractPlaceholders(original);
    final translatedPlaceholders = extractPlaceholders(translated);
    
    if (originalPlaceholders.length != translatedPlaceholders.length) {
      return false;
    }
    
    for (final placeholder in originalPlaceholders) {
      if (!translatedPlaceholders.contains(placeholder)) {
        return false;
      }
    }
    
    return true;
  }

  /// Generate translated JSON with same structure
  static Map<String, dynamic> generateTranslatedJson(
    Map<String, dynamic> originalJson,
    List<TranslationItem> translationItems,
  ) {
    final Map<String, dynamic> result = Map.from(originalJson);
    
    for (final item in translationItems) {
      if (item.isCompleted && item.translatedValue.isNotEmpty) {
        _setNestedValue(result, item.key, item.translatedValue);
      }
    }
    
    return result;
  }

  /// Set nested value in JSON structure
  static void _setNestedValue(Map<String, dynamic> map, String key, dynamic value) {
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

  /// Validate JSON structure
  static bool isValidJson(String jsonString) {
    try {
      json.decode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class JsonParserException implements Exception {
  final String message;
  JsonParserException(this.message);
  
  @override
  String toString() => 'JsonParserException: $message';
}

