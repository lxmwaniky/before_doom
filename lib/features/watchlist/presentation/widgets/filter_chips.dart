import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  final String? activeFilter;
  final ValueChanged<String?> onFilterChanged;

  const FilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            context: context,
            label: 'All',
            value: null,
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Essential',
            value: 'essential',
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Movies',
            value: 'movies',
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Complete',
            value: 'completionist',
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required String? value,
    required ThemeData theme,
  }) {
    final isActive = activeFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onFilterChanged(value),
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : theme.colorScheme.onSurface,
      ),
      side: BorderSide(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}
