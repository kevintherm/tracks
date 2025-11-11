import 'package:flutter/material.dart';
import 'package:tracks/utils/toast.dart';

/// Generic reorderable configuration section
/// T is the type of exercise option (must have id)
/// C is the type of configuration
class ConfigSection<T, C> extends StatefulWidget {
  final List<T> selectedOptions;
  final Map<String, C> configurations;
  final void Function(int, int) onReorder;
  final void Function(int)? onDelete;
  final String Function(T) getId;
  final String Function(T) getLabel;
  final Widget Function(T, int, C, VoidCallback?, VoidCallback?) itemBuilder;
  final C Function() defaultConfig;
  final ScrollController? scrollController;
  final bool enableReordering;
  final bool enableReorderAnimation;
  final bool showReorderToast;
  final bool autoScrollToReorderedItem;
  final bool showDeleteConfirmation;

  const ConfigSection({
    super.key,
    required this.selectedOptions,
    required this.configurations,
    required this.onReorder,
    this.onDelete,
    required this.getId,
    required this.getLabel,
    required this.itemBuilder,
    required this.defaultConfig,
    this.scrollController,
    this.enableReordering = true,
    this.enableReorderAnimation = true,
    this.showReorderToast = true,
    this.autoScrollToReorderedItem = true,
    this.showDeleteConfirmation = true,
  });

  @override
  State<ConfigSection<T, C>> createState() => _ConfigSectionState<T, C>();
}

class _ConfigSectionState<T, C> extends State<ConfigSection<T, C>> {
  final Map<String, GlobalKey> _itemKeys = {};
  final Map<int, GlobalKey> _positionKeys = {};
  String? _lastReorderedItemId;

  @override
  void initState() {
    super.initState();
    _updateKeys();
  }

  @override
  void didUpdateWidget(ConfigSection<T, C> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateKeys();
  }

  void _updateKeys() {
    // Clear position keys on update
    _positionKeys.clear();
    
    // Create position keys for each index
    for (int i = 0; i < widget.selectedOptions.length; i++) {
      _positionKeys[i] = GlobalKey();
    }
    
    // Keep item keys for tracking (not used for GlobalKey anymore)
    for (var option in widget.selectedOptions) {
      final id = widget.getId(option);
      if (!_itemKeys.containsKey(id)) {
        _itemKeys[id] = GlobalKey();
      }
    }
  }

  void _showReorderBottomSheet(BuildContext context, int currentIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReorderBottomSheet(
        currentIndex: currentIndex,
        totalItems: widget.selectedOptions.length,
        onReorder: (newIndex) {
          if (newIndex != currentIndex) {
            Navigator.pop(context);
            final option = widget.selectedOptions[currentIndex];
            final label = widget.getLabel(option);
            
            // Track the reordered item
            setState(() {
              _lastReorderedItemId = widget.getId(option);
            });
            
            widget.onReorder(currentIndex, newIndex);
            
            if (widget.showReorderToast) {
              Toast(context).success(
                content: Text('Moved $label to ${newIndex + 1}'),
              );
            }
            
            if (widget.autoScrollToReorderedItem && widget.scrollController != null) {
              _scrollToIndex(newIndex);
            }
            
            // Clear the reordered item flag after animation completes
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                setState(() {
                  _lastReorderedItemId = null;
                });
              }
            });
          }
        },
      ),
    );
  }

  void _handleDelete(BuildContext context, int index) {
    if (widget.onDelete == null) return;
    
    final option = widget.selectedOptions[index];
    final label = widget.getLabel(option);
    
    if (widget.showDeleteConfirmation) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to remove "$label"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete!(index);
                Toast(context).success(
                  content: Text('Removed $label'),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    } else {
      widget.onDelete!(index);
      Toast(context).success(
        content: Text('Removed $label'),
      );
    }
  }

  void _scrollToIndex(int index) {
    if (widget.scrollController == null || !widget.scrollController!.hasClients) return;
    
    // Wait for the widget to rebuild and get the actual position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index >= widget.selectedOptions.length) return;
      
      final key = _positionKeys[index];
      
      if (key?.currentContext == null) return;
      
      try {
        final RenderBox? renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.hasSize) return;
        
        final position = renderBox.localToGlobal(Offset.zero);
        final itemHeight = renderBox.size.height;
        
        // Get the current scroll offset
        final currentOffset = widget.scrollController!.offset;
        
        // Calculate where the item currently is relative to the viewport
        final double itemTop = position.dy + currentOffset;
        
        // Get viewport dimensions
        final viewportHeight = widget.scrollController!.position.viewportDimension;
        
        // Calculate target offset to center the item (or at least make it visible)
        double targetOffset = itemTop - (viewportHeight / 2) + (itemHeight / 2);
        
        // Clamp to valid scroll range
        targetOffset = targetOffset.clamp(
          widget.scrollController!.position.minScrollExtent,
          widget.scrollController!.position.maxScrollExtent,
        );
        
        // Scroll to the target position
        widget.scrollController!.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      } catch (e) {
        // If there's any error, just skip the scroll
        debugPrint('Error scrolling to item: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.selectedOptions.length,
        (index) {
          final option = widget.selectedOptions[index];
          final id = widget.getId(option);
          final config = widget.configurations[id] ?? widget.defaultConfig();
          final shouldAnimate = widget.enableReorderAnimation && _lastReorderedItemId == id;

          final cardWidget = widget.itemBuilder(
            option,
            index,
            config,
            widget.enableReordering ? () => _showReorderBottomSheet(context, index) : null,
            widget.onDelete != null ? () => _handleDelete(context, index) : null,
          );

          // Only animate the reordered item
          if (!shouldAnimate) {
            return Container(
              key: _positionKeys[index],
              child: cardWidget,
            );
          }

          return Container(
            key: _positionKeys[index],
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                // Clamp the scale to prevent overshoot beyond 1.0
                final scale = (0.8 + (value * 0.2)).clamp(0.0, 1.0);
                final opacity = value.clamp(0.0, 1.0);
                
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                );
              },
              child: cardWidget,
            ),
          );
        },
      ),
    );
  }
}

class _ReorderBottomSheet extends StatefulWidget {
  final int currentIndex;
  final int totalItems;
  final ValueChanged<int> onReorder;

  const _ReorderBottomSheet({
    required this.currentIndex,
    required this.totalItems,
    required this.onReorder,
  });

  @override
  State<_ReorderBottomSheet> createState() => _ReorderBottomSheetState();
}

class _ReorderBottomSheetState extends State<_ReorderBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Position',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Current position: ${widget.currentIndex + 1}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.totalItems,
                  itemBuilder: (context, index) {
                    final isCurrentPosition = index == widget.currentIndex;
                    return _AnimatedPositionTile(
                      index: index,
                      isCurrentPosition: isCurrentPosition,
                      onTap: isCurrentPosition
                          ? null
                          : () => widget.onReorder(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedPositionTile extends StatefulWidget {
  final int index;
  final bool isCurrentPosition;
  final VoidCallback? onTap;

  const _AnimatedPositionTile({
    required this.index,
    required this.isCurrentPosition,
    this.onTap,
  });

  @override
  State<_AnimatedPositionTile> createState() => _AnimatedPositionTileState();
}

class _AnimatedPositionTileState extends State<_AnimatedPositionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: widget.isCurrentPosition
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : (_isPressed ? Colors.grey[200] : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: CircleAvatar(
                    backgroundColor: widget.isCurrentPosition
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    child: Text(
                      '${widget.index + 1}',
                      style: TextStyle(
                        color: widget.isCurrentPosition
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  widget.isCurrentPosition
                      ? 'Current position'
                      : 'Move to position ${widget.index + 1}',
                  style: TextStyle(
                    fontWeight: widget.isCurrentPosition
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                trailing: widget.isCurrentPosition
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
