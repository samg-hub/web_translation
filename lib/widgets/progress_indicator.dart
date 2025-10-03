import 'package:flutter/material.dart';

class TranslationProgressIndicator extends StatelessWidget {
  final int completedItems;
  final int totalItems;
  final double progressPercentage;
  final bool isFullyTranslated;

  const TranslationProgressIndicator({
    super.key,
    required this.completedItems,
    required this.totalItems,
    required this.progressPercentage,
    this.isFullyTranslated = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progressPercentage / 100,
                  backgroundColor: colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFullyTranslated 
                        ? colorScheme.primary 
                        : colorScheme.secondary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${progressPercentage.toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFullyTranslated 
                      ? colorScheme.primary 
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Statistics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Completed',
                completedItems.toString(),
                colorScheme.primary,
                Icons.check_circle,
              ),
              _buildStatItem(
                context,
                'Pending',
                (totalItems - completedItems).toString(),
                colorScheme.secondary,
                Icons.pending,
              ),
              _buildStatItem(
                context,
                'Total',
                totalItems.toString(),
                colorScheme.onSurfaceVariant,
                Icons.list,
              ),
            ],
          ),
          
          if (isFullyTranslated) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    color: colorScheme.onPrimaryContainer,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Translation Complete!',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class CustomCircularProgressIndicator extends StatelessWidget {
  final int completedItems;
  final int totalItems;
  final double progressPercentage;
  final double size;

  const CustomCircularProgressIndicator({
    super.key,
    required this.completedItems,
    required this.totalItems,
    required this.progressPercentage,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceVariant,
            ),
          ),
          
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              strokeWidth: 6,
            ),
          ),
          
          // Center text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${progressPercentage.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$completedItems/$totalItems',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
