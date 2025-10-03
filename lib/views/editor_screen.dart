import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/translation_provider.dart';
import '../providers/file_handler_provider.dart';
import '../widgets/translation_tile.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/search_bar.dart';
import 'export_screen.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Completed',
    'Pending',
    'With Placeholders',
  ];

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(translationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!translationState.hasProject) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editor'),
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'No project loaded',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please import a JSON file first',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final jsonStructure = translationState.jsonStructure!;
    final filteredItems = _getFilteredItems(translationState);

    return Scaffold(
      appBar: AppBar(
        title: Text(jsonStructure.fileName),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveProject(context, ref),
            tooltip: 'Save Project',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportProject(context, ref),
            tooltip: 'Export',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear All Translations'),
              ),
              const PopupMenuItem(
                value: 'complete_all',
                child: Text('Complete All Pending'),
              ),
              const PopupMenuItem(
                value: 'validate',
                child: Text('Validate Translations'),
              ),
            ],
            onSelected: (value) => _handleMenuAction(context, ref, value),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: TranslationProgressIndicator(
              completedItems: translationState.completedItems,
              totalItems: translationState.totalItems,
              progressPercentage: translationState.progressPercentage,
              isFullyTranslated: translationState.isFullyTranslated,
            ),
          ),
          
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TranslationSearchBar(
                  onChanged: (query) {
                    ref.read(translationProvider.notifier).setSearchQuery(query);
                  },
                ),
                const SizedBox(height: 12),
                FilterChips(
                  options: _filterOptions,
                  selectedOption: _selectedFilter,
                  onChanged: (option) {
                    setState(() {
                      _selectedFilter = option ?? 'All';
                    });
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Translation items list
          Expanded(
            child: filteredItems.isEmpty
                ? _buildEmptyState(context, theme, colorScheme)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return TranslationTile(
                        key: ValueKey(item.key),
                        item: item,
                        onTranslationChanged: (value) {
                          ref.read(translationProvider.notifier)
                              .updateTranslation(item.key, value);
                        },
                        onCompletedChanged: (completed) {
                          ref.read(translationProvider.notifier)
                              .markAsCompleted(item.key, completed);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: translationState.isFullyTranslated
          ? FloatingActionButton.extended(
              onPressed: () => _exportProject(context, ref),
              icon: const Icon(Icons.download),
              label: const Text('Export'),
            )
          : null,
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyStateIcon(),
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateTitle(),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateSubtitle(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getEmptyStateIcon() {
    switch (_selectedFilter) {
      case 'Completed':
        return Icons.check_circle_outline;
      case 'Pending':
        return Icons.pending_outlined;
      case 'With Placeholders':
        return Icons.code;
      default:
        return Icons.search_off;
    }
  }

  String _getEmptyStateTitle() {
    switch (_selectedFilter) {
      case 'Completed':
        return 'No completed translations';
      case 'Pending':
        return 'No pending translations';
      case 'With Placeholders':
        return 'No items with placeholders';
      default:
        return 'No items found';
    }
  }

  String _getEmptyStateSubtitle() {
    switch (_selectedFilter) {
      case 'Completed':
        return 'Complete some translations to see them here';
      case 'Pending':
        return 'All translations are completed!';
      case 'With Placeholders':
        return 'No items contain placeholders';
      default:
        return 'Try adjusting your search or filter';
    }
  }

  List<dynamic> _getFilteredItems(TranslationState state) {
    final notifier = ref.read(translationProvider.notifier);
    List<dynamic> items = notifier.getFilteredItems();
    
    switch (_selectedFilter) {
      case 'Completed':
        items = notifier.getItemsByStatus(true);
        break;
      case 'Pending':
        items = notifier.getItemsByStatus(false);
        break;
      case 'With Placeholders':
        items = notifier.getItemsWithPlaceholders();
        break;
    }
    
    return items;
  }

  Future<void> _saveProject(BuildContext context, WidgetRef ref) async {
    final translationState = ref.read(translationProvider);
    final fileHandlerNotifier = ref.read(fileHandlerProvider.notifier);
    
    if (translationState.hasProject) {
      await fileHandlerNotifier.saveProject(translationState.jsonStructure!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _exportProject(BuildContext context, WidgetRef ref) {
    final translationState = ref.read(translationProvider);
    
    if (translationState.hasProject) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExportScreen(
            jsonStructure: translationState.jsonStructure!,
          ),
        ),
      );
    }
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    final translationNotifier = ref.read(translationProvider.notifier);
    
    switch (action) {
      case 'clear_all':
        _showConfirmDialog(
          context,
          'Clear All Translations',
          'Are you sure you want to clear all translations? This action cannot be undone.',
          () {
            translationNotifier.clearAllTranslations();
            Navigator.of(context).pop();
          },
        );
        break;
      case 'complete_all':
        _showConfirmDialog(
          context,
          'Complete All Pending',
          'Are you sure you want to mark all pending items as completed?',
          () {
            translationNotifier.completeAllPending();
            Navigator.of(context).pop();
          },
        );
        break;
      case 'validate':
        _validateTranslations(context, ref);
        break;
    }
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onConfirm,
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _validateTranslations(BuildContext context, WidgetRef ref) {
    final translationNotifier = ref.read(translationProvider.notifier);
    final errors = translationNotifier.validateTranslations();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Results'),
        content: SizedBox(
          width: double.maxFinite,
          child: errors.isEmpty
              ? const Text('All translations are valid!')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: errors.map((error) => Text('• $error')).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
