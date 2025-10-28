import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';

// --- Models (for Type Safety) ---

class ExerciseOption {
  final String id;
  final String label;

  ExerciseOption({required this.id, required this.label});

  // Add equals and hashCode for proper list comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// --- Page Widget ---

class CreateWorkoutPage extends StatefulWidget {
  const CreateWorkoutPage({super.key});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  bool _useFirstExerciseThumbnail = false;
  final ScrollController _scrollController = ScrollController();

  final List<ExerciseOption> _selectOptions = [
    ExerciseOption(label: 'Apple', id: '123'),
    ExerciseOption(label: 'Banana', id: '1234'),
    ExerciseOption(label: 'Mango', id: '12345'),
    ExerciseOption(label: 'Cherry', id: '123451'),
    ExerciseOption(label: 'Pier', id: '123452'),
  ];
  final List<ExerciseOption> _selectedOptions = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- List Management Methods ---

  void _onExerciseSelected(ExerciseOption option) {
    final currentScroll = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    setState(() {
      _selectedOptions.add(option);
      _selectOptions.remove(option);
    });

    // Restore scroll position after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(currentScroll);
      }
    });
  }

  void _onExerciseDeselected(ExerciseOption option) {
    final currentScroll = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    setState(() {
      _selectedOptions.remove(option);
      _selectOptions.add(option);
    });

    // Restore scroll position after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(currentScroll);
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _selectedOptions.removeAt(oldIndex);
      _selectedOptions.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Extracted AppBar
              _AppBar(),

              // Extracted Thumbnail Section
              _ThumbnailSection(
                useFirstExercise: _useFirstExerciseThumbnail,
                onChanged: (value) {
                  setState(() {
                    _useFirstExerciseThumbnail = value;
                  });
                },
              ),

              // Extracted Details Section
              _WorkoutDetailsSection(),

              // Extracted Exercises Section
              _ExercisesSection(
                selectedOptions: _selectedOptions,
                availableOptions: _selectOptions,
                onDeselect: _onExerciseDeselected,
                onSelect: _onExerciseSelected,
                onReorder: _onReorder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable Card Widget ---

const List<BoxShadow> _kCardShadow = [
  BoxShadow(
    color: Color(0xFFE0E0E0), // Colors.grey[300]!
    offset: Offset(0, 1),
    blurRadius: 2,
  ),
  BoxShadow(
    color: Color(0xFFF5F5F5), // Colors.grey[200]!
    offset: Offset(0, -2),
    blurRadius: 10,
  ),
];

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: _kCardShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// --- Extracted Page Sections ---

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Pressable(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Iconsax.arrow_left_2_outline, size: 24),
          ),
          Text(
            "New Workout",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 24), // Balance the back arrow
        ],
      ),
    );
  }
}

class _ThumbnailSection extends StatelessWidget {
  final bool useFirstExercise;
  final ValueChanged<bool> onChanged;

  const _ThumbnailSection({
    required this.useFirstExercise,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = useFirstExercise;
    final Color color = isDisabled ? Colors.grey : AppColors.secondary;

    return _CardSection(
      title: "Thumbnail",
      child: Column(
        children: [
          DottedBorder(
            options: RoundedRectDottedBorderOptions(
              dashPattern: const [10, 5],
              strokeWidth: 2,
              radius: const Radius.circular(16),
              color: color,
              padding: const EdgeInsets.all(16),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.document_upload_outline, size: 32, color: color),
                  const SizedBox(height: 8),
                  Text(
                    "Upload a thumbnail",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Use First Exercise\'s'),
            value: useFirstExercise,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _WorkoutDetailsSection extends StatelessWidget {
  const _WorkoutDetailsSection();

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: "Workout Details",
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const OutlineInputBorder _kSearchBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(32)),
  borderSide: BorderSide.none,
);

// --- MODIFIED: Converted to StatefulWidget ---
class _ExercisesSection extends StatefulWidget {
  final List<ExerciseOption> selectedOptions;
  final List<ExerciseOption> availableOptions;
  final void Function(ExerciseOption) onSelect;
  final void Function(ExerciseOption) onDeselect;
  final void Function(int, int) onReorder;

  const _ExercisesSection({
    required this.selectedOptions,
    required this.availableOptions,
    required this.onSelect,
    required this.onDeselect,
    required this.onReorder,
  });

  @override
  State<_ExercisesSection> createState() => _ExercisesSectionState();
}

class _ExercisesSectionState extends State<_ExercisesSection> {
  // --- ADDED: State for collapsibles ---
  bool _isSelectedExpanded = true;
  bool _isAvailableExpanded = true;

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: "Exercises",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search",
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
              border: _kSearchBorder,
              enabledBorder: _kSearchBorder,
              focusedBorder: _kSearchBorder,
            ),
          ),
          const SizedBox(height: 16),

          // AI Recommendation
          _AiRecommendation(),
          const SizedBox(height: 16),

          // --- MODIFIED: Selected List Group (always show, collapsed if empty) ---
          // --- ADDED: Collapsible Header ---
          InkWell(
            onTap: widget.selectedOptions.isNotEmpty
                ? () {
                    setState(() {
                      _isSelectedExpanded = !_isSelectedExpanded;
                    });
                  }
                : null, // Disable tap when empty
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Selected (${widget.selectedOptions.length})",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.selectedOptions.isEmpty
                          ? Colors.grey[400]
                          : null,
                    ),
                  ),
                  if (widget.selectedOptions.isNotEmpty)
                    Icon(
                      _isSelectedExpanded
                          ? Iconsax.arrow_up_2_outline
                          : Iconsax.arrow_down_1_outline,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                ],
              ),
            ),
          ),
          // --- ADDED: AnimatedSize wrapper ---
          if (widget.selectedOptions.isNotEmpty)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isSelectedExpanded
                  ? ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      onReorder: widget.onReorder,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.selectedOptions.length,
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          elevation: 8,
                          borderRadius: BorderRadius.circular(16),
                          child: child,
                        );
                      },
                      itemBuilder: (context, index) {
                        final option = widget.selectedOptions[index];
                        return _ExerciseCheckbox(
                          key: ValueKey(option.id),
                          item: option,
                          isSelected: true,
                          order: index + 1,
                          dragIndex: index,
                          onConfirm: () => showConfirmDialog(context),
                          direction:
                              _ExerciseAnimationDirection.selectedToAvailable,
                          onChanged: widget.onDeselect,
                        );
                      },
                    )
                  : const SizedBox.shrink(), // Collapsed state
            ),

          // --- MODIFIED: Separator logic ---
          if (widget.availableOptions.isNotEmpty) const SizedBox(height: 16),

          // --- MODIFIED: Available List Group ---
          if (widget.availableOptions.isNotEmpty) ...[
            // --- ADDED: Collapsible Header ---
            InkWell(
              onTap: () {
                setState(() {
                  _isAvailableExpanded = !_isAvailableExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Available (${widget.availableOptions.length})",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      _isAvailableExpanded
                          ? Iconsax.arrow_up_2_outline
                          : Iconsax.arrow_down_1_outline,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ),
            // --- ADDED: AnimatedSize wrapper ---
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isAvailableExpanded
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.availableOptions.length,
                      itemBuilder: (context, index) {
                        final option = widget.availableOptions[index];
                        return _ExerciseCheckbox(
                          key: ValueKey(option.id),
                          item: option,
                          isSelected: false,
                          order: 0,
                          direction:
                              _ExerciseAnimationDirection.availableToSelected,
                          onChanged: widget.onSelect,
                        );
                      },
                    )
                  : const SizedBox.shrink(), // Collapsed state
            ),
          ],
        ],
      ),
    );
  }
}
// --- End of MODIFIED Section ---

class _AiRecommendation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ai-weight.svg',
                  width: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.black87,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Try recommendation!",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            PrimaryButton(
              onTap: () {},
              child: Text(
                "Use!",
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Animated Exercise Item Widget ---

// Enum for type-safe animation direction
enum _ExerciseAnimationDirection { selectedToAvailable, availableToSelected }

class _ExerciseCheckbox extends StatefulWidget {
  final ExerciseOption item;
  final bool isSelected;
  final int order;
  final int? dragIndex;
  final _ExerciseAnimationDirection direction;
  final void Function(ExerciseOption) onChanged;
  final Future<bool> Function()? onConfirm;

  const _ExerciseCheckbox({
    super.key,
    required this.isSelected,
    required this.onChanged,
    required this.order,
    required this.item,
    required this.direction,
    this.onConfirm,
    this.dragIndex,
  });

  @override
  State<_ExerciseCheckbox> createState() => _ExerciseCheckboxState();
}

class _ExerciseCheckboxState extends State<_ExerciseCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _entranceOpacityAnimation;
  late Animation<Offset> _entranceSlideAnimation;
  bool _isEntering = true;

  int selectedSets = 2;
  int selectedReps = 2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Entrance animations (fade in from position)
    _entranceOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _entranceSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    if (widget.direction == _ExerciseAnimationDirection.selectedToAvailable) {
      // Slide down + fade out (selected to available)
      _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
      );
      _slideAnimation =
          Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1.5)).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInCubic,
            ),
          );
      _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        ),
      );
    } else {
      // Pop (scale up) + slide up + fade out (available to selected)
      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
        ),
      );
      _slideAnimation =
          Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.5)).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInCubic,
            ),
          );
      _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        ),
      );
    }

    // Trigger entrance animation
    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isEntering = false;
        });
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _runExitAnimation() async {
    if (!mounted) return;
    setState(() {
      _isEntering = false;
    });

    await _animationController.forward();
    if (mounted) {
      widget.onChanged(widget.item);
      // No need to reset, widget is being removed
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use entrance animation when first appearing, exit animation when leaving
    final slidePosition = _isEntering
        ? _entranceSlideAnimation
        : _slideAnimation;
    final opacity = _isEntering ? _entranceOpacityAnimation : _opacityAnimation;
    final scale = _isEntering
        ? const AlwaysStoppedAnimation<double>(1.0)
        : _scaleAnimation;

    // --- FIX: Add a size animation ---
    // We reuse the opacity animations as they already go
    // from 0.0 -> 1.0 (on entrance) and 1.0 -> 0.0 (on exit).
    final size = _isEntering ? _entranceOpacityAnimation : _opacityAnimation;
    // --- End of FIX ---

    final content = SizeTransition(
      // --- FIX: Wrap with SizeTransition ---
      sizeFactor: size,
      child: SlideTransition(
        position: slidePosition,
        child: ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Colors.grey[100],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        if (widget.isSelected && widget.dragIndex != null)
                          ReorderableDragStartListener(
                            index: widget.dragIndex!,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Iconsax.sort_outline,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                            ),
                          )
                        else if (widget.isSelected)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Iconsax.sort_outline,
                              color: Colors.grey[600],
                              size: 24,
                            ),
                          ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/drawings/pushup.jpg',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.item.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (widget.isSelected)
                                    DottedBorder(
                                      options: RoundedRectDottedBorderOptions(
                                        dashPattern: const [10, 5],
                                        strokeWidth: 2,
                                        radius: const Radius.circular(16),
                                        color: AppColors.darkSecondary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                      ),
                                      child: Text(
                                        widget.order.toString(),
                                        style: GoogleFonts.inter(
                                          color: AppColors.darkSecondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Average of 8 sets per week",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  padding: const EdgeInsets.only(top: 8),
                                  trackHeight: 14,
                                  disabledActiveTrackColor: AppColors.accent,
                                  thumbShape: SliderComponentShape.noThumb,
                                ),
                                child: const Slider(
                                  value: 10,
                                  min: 0,
                                  max: 100,
                                  onChanged: null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Reps and set form
                    if (widget.isSelected && widget.dragIndex != null) ...[
                      const SizedBox(height: 16),

                      Text(
                        "Sets",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),

                      NumberPicker(
                        value: selectedSets,
                        minValue: 1,
                        maxValue: 20,
                        haptics: false,
                        axis: Axis.horizontal,
                        selectedTextStyle: TextStyle(fontSize: 20),
                        onChanged: (value) =>
                            setState(() => selectedSets = value),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Reps",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),

                      NumberPicker(
                        value: selectedReps,
                        minValue: 1,
                        maxValue: 20,
                        haptics: false,
                        axis: Axis.horizontal,
                        selectedTextStyle: TextStyle(fontSize: 20),
                        onChanged: (value) =>
                            setState(() => selectedReps = value),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ); // --- End of SizeTransition wrap ---

    // Wrap with Dismissible for selected items, Pressable for available items
    if (widget.isSelected) {
      return Dismissible(
        key: ValueKey(widget.item.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          if (widget.onConfirm != null) {
            final confirmed = await widget.onConfirm!();
            if (confirmed) {
              _runExitAnimation();
            }
            return confirmed; // Dismissible handles the animation
          }
          _runExitAnimation(); // Trigger exit animation
          return true; // Optimistically assume dismiss
        },
        onDismissed: (direction) {
          // The onChanged call is now handled by _runExitAnimation
          // or by confirmDismiss if it returns false
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.red[400],
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        child: content,
      );
    } else {
      return Pressable(onTap: _runExitAnimation, child: content);
    }
  }
}