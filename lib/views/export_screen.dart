import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/json_structure.dart';
import '../providers/file_handler_provider.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final JsonStructure jsonStructure;

  const ExportScreen({super.key, required this.jsonStructure});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _fileName = '';
  String _selectedFormat = 'json';
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fileName = '${widget.jsonStructure.fileName}_translated';
    _fileNameController.text = _fileName;
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileHandlerState = ref.watch(fileHandlerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Translation'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project summary
            _buildProjectSummary(context, theme, colorScheme),

            const SizedBox(height: 24),

            // Export options
            _buildExportOptions(context, theme, colorScheme),

            const SizedBox(height: 24),

            // Preview section
            _buildPreviewSection(context, theme, colorScheme),

            const SizedBox(height: 24),

            // Export buttons
            _buildExportButtons(context, theme, colorScheme),

            // Loading indicator
            if (fileHandlerState.isExporting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
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
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          ref.read(fileHandlerProvider.notifier).clearError(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSummary(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Summary',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'File Name',
                  widget.jsonStructure.fileName,
                  Icons.description,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Source Language',
                  widget.jsonStructure.sourceLanguage,
                  Icons.language,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Total Items',
                  widget.jsonStructure.totalItems.toString(),
                  Icons.list,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Completed',
                  widget.jsonStructure.completedItems.toString(),
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Progress',
                  '${widget.jsonStructure.progressPercentage.toStringAsFixed(1)}%',
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Created',
                  _formatDate(widget.jsonStructure.createdAt),
                  Icons.schedule,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExportOptions(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Options',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // File name input
          TextField(
            controller: _fileNameController,
            onChanged: (value) => setState(() => _fileName = value),
            decoration: InputDecoration(
              labelText: 'File Name',
              hintText: 'Enter file name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.edit),
            ),
          ),

          const SizedBox(height: 20),

          // Format selection
          Text(
            'Export Format',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _buildFormatOption('json', 'JSON', Icons.code),
              _buildFormatOption('csv', 'CSV', Icons.table_chart),
              _buildFormatOption('txt', 'TXT', Icons.text_snippet),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFormatOption(String value, String label, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedFormat == value;

    return InkWell(
      onTap: () => setState(() => _selectedFormat = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final translatedJson = widget.jsonStructure.getTranslatedJson();
    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(translatedJson);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: SingleChildScrollView(
              child: Text(
                jsonString,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _exportSingleFormat(),
            icon: const Icon(Icons.download),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _exportMultipleFormats(),
            icon: const Icon(Icons.file_download),
            label: const Text('Export All Formats'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _exportSingleFormat() async {
    final fileHandlerNotifier = ref.read(fileHandlerProvider.notifier);
    final fileName = '$_fileName.$_selectedFormat';

    await fileHandlerNotifier.exportJsonFile(widget.jsonStructure, fileName);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported to: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _exportMultipleFormats() async {
    final fileHandlerNotifier = ref.read(fileHandlerProvider.notifier);

    await fileHandlerNotifier.exportToMultipleFormats(
      widget.jsonStructure,
      _fileName,
    );

    if (mounted) {
      final results = ref.read(fileHandlerProvider).lastExportResults!;
      final exportedFiles = results.values.where((path) => path != null).length;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported $exportedFiles files successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
