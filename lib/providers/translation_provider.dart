import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translation_item.dart';
import '../models/json_structure.dart';
import '../services/json_parser_service.dart';

class TranslationNotifier extends StateNotifier<TranslationState> {
  TranslationNotifier() : super(const TranslationState());

  /// Load JSON file and create translation items
  Future<void> loadJsonFile(String jsonContent, String fileName) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final jsonStructure = JsonParserService.parseJsonFile(
        jsonContent: jsonContent,
        fileName: fileName,
      );
      
      state = state.copyWith(
        jsonStructure: jsonStructure,
        isLoading: false,
        searchQuery: '',
      );
    } catch (e) {
      print(e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update translation for a specific item
  void updateTranslation(String key, String translatedValue) {
    if (state.jsonStructure == null) return;

    final updatedItems = state.jsonStructure!.translationItems.map((item) {
      if (item.key == key) {
        final isCompleted = translatedValue.trim().isNotEmpty;
        final hasValidPlaceholders = item.hasPlaceholders
            ? JsonParserService.validatePlaceholders(item.originalValue, translatedValue)
            : true;

        return item.copyWith(
          translatedValue: translatedValue,
          isCompleted: isCompleted && hasValidPlaceholders,
          lastModified: DateTime.now(),
        );
      }
      return item;
    }).toList();

    final updatedJsonStructure = state.jsonStructure!.copyWith(
      translationItems: updatedItems,
      lastModified: DateTime.now(),
    );

    state = state.copyWith(jsonStructure: updatedJsonStructure);
  }

  /// Mark item as completed
  void markAsCompleted(String key, bool completed) {
    if (state.jsonStructure == null) return;

    final updatedItems = state.jsonStructure!.translationItems.map((item) {
      if (item.key == key) {
        return item.copyWith(
          isCompleted: completed,
          lastModified: DateTime.now(),
        );
      }
      return item;
    }).toList();

    final updatedJsonStructure = state.jsonStructure!.copyWith(
      translationItems: updatedItems,
      lastModified: DateTime.now(),
    );

    state = state.copyWith(jsonStructure: updatedJsonStructure);
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear all translations
  void clearAllTranslations() {
    if (state.jsonStructure == null) return;

    final updatedItems = state.jsonStructure!.translationItems.map((item) {
      return item.copyWith(
        translatedValue: '',
        isCompleted: false,
        lastModified: DateTime.now(),
      );
    }).toList();

    final updatedJsonStructure = state.jsonStructure!.copyWith(
      translationItems: updatedItems,
      lastModified: DateTime.now(),
    );

    state = state.copyWith(jsonStructure: updatedJsonStructure);
  }

  /// Complete all pending translations with empty values
  void completeAllPending() {
    if (state.jsonStructure == null) return;

    final updatedItems = state.jsonStructure!.translationItems.map((item) {
      if (!item.isCompleted) {
        return item.copyWith(
          translatedValue: item.translatedValue.isEmpty ? item.originalValue : item.translatedValue,
          isCompleted: true,
          lastModified: DateTime.now(),
        );
      }
      return item;
    }).toList();

    final updatedJsonStructure = state.jsonStructure!.copyWith(
      translationItems: updatedItems,
      lastModified: DateTime.now(),
    );

    state = state.copyWith(jsonStructure: updatedJsonStructure);
  }

  /// Get filtered translation items based on search query
  List<TranslationItem> getFilteredItems() {
    if (state.jsonStructure == null) return [];
    
    final items = state.jsonStructure!.translationItems;
    
    if (state.searchQuery.isEmpty) return items;
    
    final query = state.searchQuery.toLowerCase();
    return items.where((item) {
      return item.key.toLowerCase().contains(query) ||
             item.originalValue.toLowerCase().contains(query) ||
             item.translatedValue.toLowerCase().contains(query);
    }).toList();
  }

  /// Get items by completion status
  List<TranslationItem> getItemsByStatus(bool completed) {
    return getFilteredItems().where((item) => item.isCompleted == completed).toList();
  }

  /// Get items with placeholders
  List<TranslationItem> getItemsWithPlaceholders() {
    return getFilteredItems().where((item) => item.hasPlaceholders).toList();
  }

  /// Validate all translations
  List<String> validateTranslations() {
    final errors = <String>[];
    
    if (state.jsonStructure == null) return errors;
    
    for (final item in state.jsonStructure!.translationItems) {
      if (item.isCompleted && item.hasPlaceholders) {
        if (!JsonParserService.validatePlaceholders(item.originalValue, item.translatedValue)) {
          errors.add('Placeholder validation failed for key: ${item.key}');
        }
      }
    }
    
    return errors;
  }

  /// Reset state
  void reset() {
    state = const TranslationState();
  }
}

class TranslationState {
  final JsonStructure? jsonStructure;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const TranslationState({
    this.jsonStructure,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  TranslationState copyWith({
    JsonStructure? jsonStructure,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return TranslationState(
      jsonStructure: jsonStructure ?? this.jsonStructure,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasProject => jsonStructure != null;
  bool get hasError => error != null;
  int get totalItems => jsonStructure?.totalItems ?? 0;
  int get completedItems => jsonStructure?.completedItems ?? 0;
  int get pendingItems => jsonStructure?.pendingItems ?? 0;
  double get progressPercentage => jsonStructure?.progressPercentage ?? 0.0;
  bool get isFullyTranslated => jsonStructure?.isFullyTranslated ?? false;
}

final translationProvider = StateNotifierProvider<TranslationNotifier, TranslationState>(
  (ref) => TranslationNotifier(),
);

