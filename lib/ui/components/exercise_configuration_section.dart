import 'package:flutter/material.dart';

/// Generic reorderable configuration section
/// T is the type of exercise option (must have id)
/// C is the type of configuration
class ExerciseConfigurationSection<T, C> extends StatelessWidget {
  final List<T> selectedOptions;
  final Map<String, C> configurations;
  final void Function(int, int) onReorder;
  final String Function(T) getId;
  final Widget Function(T, int, C) itemBuilder;
  final C Function() defaultConfig;

  const ExerciseConfigurationSection({
    super.key,
    required this.selectedOptions,
    required this.configurations,
    required this.onReorder,
    required this.getId,
    required this.itemBuilder,
    required this.defaultConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      onReorder: onReorder,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: selectedOptions.length,
      proxyDecorator: (child, index, animation) {
        return Material(
          color: Colors.transparent,
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final option = selectedOptions[index];
        final id = getId(option);
        final config = configurations[id] ?? defaultConfig();

        return itemBuilder(option, index, config);
      },
    );
  }
}
