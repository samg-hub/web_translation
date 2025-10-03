import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/translation_item.dart';
import '../services/json_parser_service.dart';

class TranslationTile extends StatefulWidget {
  final TranslationItem item;
  final ValueChanged<String> onTranslationChanged;
  final ValueChanged<bool> onCompletedChanged;
  final bool isSelected;
  final VoidCallback? onTap;

  const TranslationTile({
    super.key,
    required this.item,
    required this.onTranslationChanged,
    required this.onCompletedChanged,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<TranslationTile> createState() => _TranslationTileState();
}

class _TranslationTileState extends State<TranslationTile> {
  late TextEditingController _controller;
  bool _isValid = true;
  String _validationError = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.translatedValue);
    _validateTranslation();
  }

  @override
  void didUpdateWidget(TranslationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.translatedValue != widget.item.translatedValue) {
      _controller.text = widget.item.translatedValue;
      _validateTranslation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateTranslation() {
    if (widget.item.hasPlaceholders) {
      final isValid = JsonParserService.validatePlaceholders(
        widget.item.originalValue,
        _controller.text,
      );

      setState(() {
        _isValid = isValid;
        _validationError = isValid ? '' : 'Placeholder validation failed';
      });
    } else {
      setState(() {
        _isValid = true;
        _validationError = '';
      });
    }
  }

  void _onTextChanged(String value) {
    widget.onTranslationChanged(value);
    _validateTranslation();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: widget.isSelected ? 8 : 2,
      color: widget.isSelected
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with key and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.key,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  if (widget.item.hasPlaceholders)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Placeholders',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: widget.item.isCompleted,
                    onChanged: (value) {
                      widget.onCompletedChanged(value ?? false);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Original text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original (${widget.item.originalValue.length} chars)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.originalValue,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Translation input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Translation',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (!_isValid)
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _controller,
                    onChanged: _onTextChanged,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter translation...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _isValid
                              ? colorScheme.outline
                              : colorScheme.error,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _isValid
                              ? colorScheme.outline
                              : colorScheme.error,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _isValid
                              ? colorScheme.primary
                              : colorScheme.error,
                          width: 2,
                        ),
                      ),
                      errorText: _validationError.isNotEmpty
                          ? _validationError
                          : null,
                    ),
                  ),
                ],
              ),

              // Placeholder indicators
              if (widget.item.hasPlaceholders) ...[
                const SizedBox(height: 8),
                _buildPlaceholderIndicators(),
              ],

              // Metadata
              if (widget.item.metadata != null) ...[
                const SizedBox(height: 8),
                _buildMetadata(),
              ],

              // Last modified
              if (widget.item.lastModified != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last modified: ${_formatDateTime(widget.item.lastModified!)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIndicators() {
    final placeholders = JsonParserService.extractPlaceholders(
      widget.item.originalValue,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: placeholders.map((placeholder) {
        return GestureDetector(
          onTap: () => _copyPlaceholderToClipboard('{{$placeholder}}'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '{{$placeholder}}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.copy,
                  size: 12,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _copyPlaceholderToClipboard(String placeholder) async {
    try {
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: placeholder));

      // Also insert it into the text field at cursor position
      final currentText = _controller.text;
      final cursorPosition = _controller.selection.baseOffset;

      final newText =
          currentText.substring(0, cursorPosition) +
          placeholder +
          currentText.substring(cursorPosition);

      _controller.text = newText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition + placeholder.length),
      );

      // Trigger the change
      _onTextChanged(newText);
    } catch (e) {
      // Fallback: just insert into text field
      final currentText = _controller.text;
      final cursorPosition = _controller.selection.baseOffset;

      final newText =
          currentText.substring(0, cursorPosition) +
          placeholder +
          currentText.substring(cursorPosition);

      _controller.text = newText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition + placeholder.length),
      );

      _onTextChanged(newText);
    }
  }

  Widget _buildMetadata() {
    final metadata = widget.item.metadata!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (metadata.description != null) ...[
            Text(
              'Description: ${metadata.description}',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
          ],
          if (metadata.context != null) ...[
            Text(
              'Context: ${metadata.context}',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
          ],
          if (metadata.placeholders != null &&
              metadata.placeholders!.isNotEmpty) ...[
            Text(
              'Placeholder Types:',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            ...metadata.placeholders!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${entry.key}: ${entry.value.type}',
                  style: theme.textTheme.labelSmall,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
