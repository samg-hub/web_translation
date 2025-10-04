import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/translation_provider.dart';
import '../providers/file_handler_provider.dart';
import 'editor_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationProvider);
    final fileHandlerState = ref.watch(fileHandlerProvider);
    ref.listen(fileHandlerProvider, (previous, next) {
      print('fileHandlerState: $fileHandlerState');
    });
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Translation Editor'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Welcome section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.translate,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'JSON Translation Editor',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Import JSON files, translate strings, and export translated content',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action buttons
                Column(
                  children: [
                    _buildActionButton(
                      context,
                      'Import JSON File',
                      'Load a JSON file to start translating',
                      Icons.upload_file,
                      colorScheme.primary,
                      () => _importJsonFile(context, ref),
                    ),

                    // const SizedBox(height: 16),

                    // _buildActionButton(
                    //   context,
                    //   'Continue Last Project',
                    //   'Resume your previous translation work',
                    //   Icons.restore,
                    //   colorScheme.secondary,
                    //   translationState.hasProject
                    //       ? () => _continueProject(context, ref)
                    //       : null,
                    // ),
                    // const SizedBox(height: 16),

                    // _buildActionButton(
                    //   context,
                    //   'View Saved Projects',
                    //   'Browse and manage your saved projects',
                    //   Icons.folder,
                    //   colorScheme.tertiary,
                    //   () => _showSavedProjects(context, ref),
                    // ),
                  ],
                ),

                const Spacer(),

                // Recent projects section
                // if (fileHandlerState.savedProjects.isNotEmpty) ...[
                //   Container(
                //     width: double.infinity,
                //     padding: const EdgeInsets.all(16),
                //     decoration: BoxDecoration(
                //       color: colorScheme.surfaceContainerHighest.withValues(
                //         alpha: 0.3,
                //       ),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           'Recent Projects',
                //           style: theme.textTheme.titleMedium?.copyWith(
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         const SizedBox(height: 8),
                //         ...fileHandlerState.savedProjects.take(3).map((
                //           project,
                //         ) {
                //           return ListTile(
                //             leading: const Icon(Icons.description),
                //             title: Text(project['fileName']),
                //             subtitle: Text(
                //               'Saved: ${_formatDate(project['savedAt'])}',
                //             ),
                //             onTap: () =>
                //                 _loadProject(context, ref, project['filePath']),
                //           );
                //         }),
                //       ],
                //     ),
                //   ),
                // ],

                // Loading indicator
                if (fileHandlerState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),

                // Error message
                if (fileHandlerState.hasError)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fileHandlerState.error!,
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => ref
                              .read(fileHandlerProvider.notifier)
                              .clearError(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (onPressed != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onPrimary,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _importJsonFile(BuildContext context, WidgetRef ref) async {
    final fileHandlerNotifier = ref.read(fileHandlerProvider.notifier);
    final translationNotifier = ref.read(translationProvider.notifier);

    await fileHandlerNotifier.importJsonFile();

    if (fileHandlerNotifier.state.hasImportedContent) {
      final content = fileHandlerNotifier.state.importedContent!;
      final fileName = 'imported_${DateTime.now().millisecondsSinceEpoch}.json';

      await translationNotifier.loadJsonFile(content, fileName);

      if (context.mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const EditorScreen()));
      }
    }
  }

  void _continueProject(BuildContext context, WidgetRef ref) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EditorScreen()));
  }

  void _showSavedProjects(BuildContext context, WidgetRef ref) {
    final fileHandlerNotifier = ref.read(fileHandlerProvider.notifier);
    fileHandlerNotifier.loadSavedProjects();

    showDialog(context: context, builder: (context) => _SavedProjectsDialog());
  }

  Future<void> _loadProject(
    BuildContext context,
    WidgetRef ref,
    String filePath,
  ) async {
    final fileHandlerNotifier = ref.read(fileHandlerProvider.notifier);
    final translationNotifier = ref.read(translationProvider.notifier);

    await fileHandlerNotifier.loadProject(filePath);

    if (fileHandlerNotifier.state.hasLoadedProject) {
      final jsonStructure = fileHandlerNotifier.state.loadedProject!;

      // Instead of loading from originalJson, use the complete JsonStructure
      // This preserves all translation data
      translationNotifier.loadJsonStructure(jsonStructure);

      if (context.mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const EditorScreen()));
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}

class _SavedProjectsDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileHandlerState = ref.watch(fileHandlerProvider);

    return AlertDialog(
      title: const Text('Saved Projects'),
      content: SizedBox(
        width: double.maxFinite,
        child: fileHandlerState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : fileHandlerState.savedProjects.isEmpty
            ? const Center(child: Text('No saved projects found'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: fileHandlerState.savedProjects.length,
                itemBuilder: (context, index) {
                  final project = fileHandlerState.savedProjects[index];
                  return ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(project['fileName']),
                    subtitle: Text('Saved: ${_formatDate(project['savedAt'])}'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'load', child: Text('Load')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'load') {
                          Navigator.of(context).pop();
                          _loadProject(context, ref, project['filePath']);
                        } else if (value == 'delete') {
                          _deleteProject(context, ref, project['filePath']);
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _loadProject(context, ref, project['filePath']);
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _loadProject(
    BuildContext context,
    WidgetRef ref,
    String filePath,
  ) async {
    final fileHandlerNotifier = ref.read(fileHandlerProvider.notifier);
    final translationNotifier = ref.read(translationProvider.notifier);

    await fileHandlerNotifier.loadProject(filePath);

    if (fileHandlerNotifier.state.hasLoadedProject) {
      final jsonStructure = fileHandlerNotifier.state.loadedProject!;

      // Instead of loading from originalJson, use the complete JsonStructure
      // This preserves all translation data
      translationNotifier.loadJsonStructure(jsonStructure);

      if (context.mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const EditorScreen()));
      }
    }
  }

  Future<void> _deleteProject(
    BuildContext context,
    WidgetRef ref,
    String filePath,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final fileHandlerNotifier = ref.read(fileHandlerProvider.notifier);
      await fileHandlerNotifier.deleteProject(filePath);
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
