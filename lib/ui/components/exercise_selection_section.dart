import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

const OutlineInputBorder kSearchBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(32)),
  borderSide: BorderSide.none,
);

/// Generic exercise selection widget with search and AI recommendation
/// T is the type of exercise option (must have id and label)
class ExerciseSelectionSection<T> extends StatefulWidget {
  final List<T> allOptions;
  final List<T> selectedOptions;
  final void Function(T, bool) onToggle;
  final String Function(T) getLabel;
  final String Function(T) getId;
  final Widget Function(T, bool, ValueChanged<bool>) itemBuilder;
  final Widget? aiRecommendation;
  final String searchHint;

  const ExerciseSelectionSection({
    super.key,
    required this.allOptions,
    required this.selectedOptions,
    required this.onToggle,
    required this.getLabel,
    required this.getId,
    required this.itemBuilder,
    this.aiRecommendation,
    this.searchHint = "Search",
  });

  @override
  State<ExerciseSelectionSection<T>> createState() =>
      _ExerciseSelectionSectionState<T>();
}

class _ExerciseSelectionSectionState<T>
    extends State<ExerciseSelectionSection<T>> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredOptions = widget.allOptions.where((option) {
      return widget
          .getLabel(option)
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: widget.searchHint,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
            prefixIcon: const Icon(Iconsax.search_normal_1_outline, size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            border: kSearchBorder,
            enabledBorder: kSearchBorder,
            focusedBorder: kSearchBorder,
          ),
        ),
        const SizedBox(height: 16),

        // AI Recommendation (optional)
        if (widget.aiRecommendation != null) ...[
          widget.aiRecommendation!,
          const SizedBox(height: 16),
        ],

        // Exercise List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredOptions.length,
          itemBuilder: (context, index) {
            final option = filteredOptions[index];
            final isSelected = widget.selectedOptions.any(
              (selected) => widget.getId(selected) == widget.getId(option),
            );

            return widget.itemBuilder(
              option,
              isSelected,
              (value) => widget.onToggle(option, value),
            );
          },
        ),
      ],
    );
  }
}
