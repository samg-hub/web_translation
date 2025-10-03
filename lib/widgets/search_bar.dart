import 'package:flutter/material.dart';

class TranslationSearchBar extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final List<String>? suggestions;
  final ValueChanged<String>? onSuggestionSelected;

  const TranslationSearchBar({
    super.key,
    this.hintText = 'Search translations...',
    this.initialValue,
    required this.onChanged,
    this.onClear,
    this.suggestions,
    this.onSuggestionSelected,
  });

  @override
  State<TranslationSearchBar> createState() => _TranslationSearchBarState();
}

class _TranslationSearchBarState extends State<TranslationSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    widget.onChanged(value);
    setState(() {
      _showSuggestions = value.isNotEmpty && 
                        widget.suggestions != null && 
                        widget.suggestions!.isNotEmpty;
    });
  }

  void _onSuggestionSelected(String suggestion) {
    _controller.text = suggestion;
    widget.onSuggestionSelected?.call(suggestion);
    widget.onChanged(suggestion);
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus 
                  ? colorScheme.primary 
                  : colorScheme.outline.withOpacity(0.3),
            ),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            onTap: () {
              setState(() {
                _showSuggestions = _controller.text.isNotEmpty && 
                                 widget.suggestions != null && 
                                 widget.suggestions!.isNotEmpty;
              });
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        
        // Suggestions dropdown
        if (_showSuggestions && widget.suggestions != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: widget.suggestions!.take(5).map((suggestion) {
                return InkWell(
                  onTap: () => _onSuggestionSelected(suggestion),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class FilterChips extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onChanged;

  const FilterChips({
    super.key,
    required this.options,
    this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All option
          _buildChip(
            context,
            'All',
            selectedOption == null,
            () => onChanged(null),
          ),
          
          const SizedBox(width: 8),
          
          // Other options
          ...options.map((option) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildChip(
              context,
              option,
              selectedOption == option,
              () => onChanged(option),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: colorScheme.surfaceVariant,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
            ? colorScheme.onPrimaryContainer 
            : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected 
            ? colorScheme.primary 
            : colorScheme.outline.withOpacity(0.3),
      ),
    );
  }
}

