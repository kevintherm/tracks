import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/utils/fuzzy_search.dart';

const OutlineInputBorder kSearchBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16.00)),
  borderSide: BorderSide.none,
);

class SelectConfig<T> extends StatefulWidget {
  final List<T> allOptions;
  final List<T> selectedOptions;
  final void Function(T, bool) onToggle;
  final String Function(T) getLabel;
  final String Function(T) getId;
  final Widget Function(T, bool, ValueChanged<bool>) itemBuilder;
  final Widget? aiRecommendation;
  final String searchHint;
  final int limitItems;

  const SelectConfig({
    super.key,
    required this.allOptions,
    required this.selectedOptions,
    required this.onToggle,
    required this.getLabel,
    required this.getId,
    required this.itemBuilder,
    this.aiRecommendation,
    this.searchHint = "Search",
    this.limitItems = 12,
  });

  @override
  _SelectConfigState<T> createState() => _SelectConfigState<T>();
}

class _SelectConfigState<T> extends State<SelectConfig<T>> {
  String _searchQuery = '';
  late List<T> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _updateFilteredOptions();
  }

  @override
  void didUpdateWidget(SelectConfig<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allOptions != widget.allOptions) {
      _updateFilteredOptions();
    }
  }

  void _updateFilteredOptions() {
    _filteredOptions = FuzzySearch.search(
      items: widget.allOptions,
      query: _searchQuery,
      getSearchableText: widget.getLabel,
      threshold: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _updateFilteredOptions();
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

        // List Item
        SizedBox(
          height: 350,
          child: _filteredOptions.isNotEmpty
              ? ListView.builder(
                  itemCount: _filteredOptions.length > widget.limitItems
                      ? widget.limitItems
                      : _filteredOptions.length,
                  itemBuilder: (context, index) {
                    final option = _filteredOptions[index];
                    final isSelected = widget.selectedOptions.any(
                      (selected) =>
                          widget.getId(selected) == widget.getId(option),
                    );

                    return widget.itemBuilder(
                      option,
                      isSelected,
                      (value) => widget.onToggle(option, value),
                    );
                  },
                )
              : Center(
                  child: Text(
                    "No exercise available.",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
