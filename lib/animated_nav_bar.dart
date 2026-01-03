import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class AnimatedNavBar extends StatefulWidget {
  /// List of icons to display in the navigation bar.
  final List<IconData> icons;

  /// The index of the currently selected tab.
  final int selectedIndex;

  /// Callback when a tab is selected.
  final ValueChanged<int> onTabSelected;

  /// The [PageController] to listen to for scroll events and drag gestures.
  /// This allows the nav bar to sync with the PageView.
  final PageController pageController;

  // Customization Options
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double height;
  final double indicatorWidth;
  final double indicatorHeight;
  final double iconSize;
  final BorderRadius? borderRadius;

  const AnimatedNavBar({
    Key? key,
    required this.icons,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.pageController,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.height = 70.0,
    this.indicatorWidth = 70.0,
    this.indicatorHeight = 60.0,
    this.iconSize = 28.0,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  // To listen to the scroll start/end events from the PageView
  ValueNotifier<bool>? _isScrollingNotifier;

  // A handle to manually control the PageView's scrolling
  Drag? _drag;

  @override
  void initState() {
    super.initState();
    // Controls the "Scale Up" effect when touching the bar OR swiping pages
    // Reduced to 50ms for a very fast, snappy response
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
  }

  @override
  void dispose() {
    // Clean up the listener
    _isScrollingNotifier?.removeListener(_onScrollStatusChanged);
    _scaleController.dispose();
    super.dispose();
  }

  // Trigger scale based on scroll status
  void _onScrollStatusChanged() {
    if (_isScrollingNotifier?.value ?? false) {
      _scaleController.forward(); // Scale up when scrolling starts
    } else {
      _scaleController.reverse(); // Scale down when scrolling stops
    }
  }

  @override
  Widget build(BuildContext context) {
    // Attach listener to PageController if available
    if (widget.pageController.hasClients) {
      final notifier = widget.pageController.position.isScrollingNotifier;
      if (_isScrollingNotifier != notifier) {
        _isScrollingNotifier?.removeListener(_onScrollStatusChanged);
        _isScrollingNotifier = notifier;
        _isScrollingNotifier?.addListener(_onScrollStatusChanged);
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    const double horizontalMargin = 16.0;
    final double barWidth = screenWidth - (horizontalMargin * 2);
    final int itemCount = widget.icons.length;
    final double itemWidth = barWidth / itemCount;

    // Default colors
    final bg = widget.backgroundColor ?? Colors.black.withOpacity(0.3);
    final indicatorCol =
        widget.indicatorColor ?? Colors.white.withOpacity(0.15);
    final selVal = widget.selectedItemColor ?? Colors.white;
    final unselVal =
        widget.unselectedItemColor ?? Colors.white.withOpacity(0.5);

    return GestureDetector(
      // 1. Handle Scale Animation on Touch
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),

      // 2. Start Drag: Initialize manual control over the PageController
      onHorizontalDragStart: (details) {
        _scaleController.forward();
        if (widget.pageController.hasClients) {
          // This tells the PageView "The user is dragging you now"
          // so it won't try to snap back while we are moving it.
          _drag = widget.pageController.position.drag(
            DragStartDetails(
              globalPosition: details.globalPosition,
              localPosition: details.localPosition,
            ),
            () {
              _drag = null;
            },
          );
        }
      },

      // 3. Update Drag: Move the page in sync with the finger
      onHorizontalDragUpdate: (details) {
        if (_drag == null) return;

        // Ratio: ScreenWidth / ItemWidth (e.g. 4.0)
        final double conversionFactor = screenWidth / itemWidth;

        // Invert the delta.
        // Dragging RIGHT on bar (positive delta) -> Scroll LEFT on PageView (negative delta)
        // to show the NEXT page.
        final double scaledDelta = -details.delta.dx * conversionFactor;
        final double scaledPrimaryDelta =
            -(details.primaryDelta ?? 0) * conversionFactor;

        _drag!.update(
          DragUpdateDetails(
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
            delta: Offset(scaledDelta, 0),
            primaryDelta: scaledPrimaryDelta,
            sourceTimeStamp: details.sourceTimeStamp,
          ),
        );
      },

      // 4. End Drag: Let the PageView physics snap to the nearest page
      onHorizontalDragEnd: (details) {
        _scaleController.reverse();

        if (_drag == null) return;

        final double conversionFactor = screenWidth / itemWidth;

        // Invert and scale the velocity so the "fling" feels natural
        final Velocity scaledVelocity = Velocity(
          pixelsPerSecond: Offset(
            -details.velocity.pixelsPerSecond.dx * conversionFactor,
            -details.velocity.pixelsPerSecond.dy * conversionFactor,
          ),
        );

        // This triggers the PageView's built-in ballistic simulation
        // It will automatically snap to the nearest/next tab based on velocity.
        _drag!.end(
          DragEndDetails(
            velocity: scaledVelocity,
            primaryVelocity: -(details.primaryVelocity ?? 0) * conversionFactor,
          ),
        );
      },

      onHorizontalDragCancel: () {
        _scaleController.reverse();
        _drag?.cancel();
      },

      child: Container(
        margin: const EdgeInsets.all(horizontalMargin),
        height: widget.height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(35),
        ),
        child: Stack(
          children: [
            // 3. The Animated Highlighter Pill
            ListenableBuilder(
              listenable: widget.pageController,
              builder: (context, child) {
                // Determine the current "page" value
                final double page =
                    widget.pageController.hasClients &&
                        widget.pageController.position.hasContentDimensions
                    ? widget.pageController.page ??
                          widget.selectedIndex.toDouble()
                    : widget.selectedIndex.toDouble();

                // Calculate where the pill should be based on the page
                final double pillLeftPosition =
                    page * itemWidth + (itemWidth - widget.indicatorWidth) / 2;

                return Positioned(
                  left: pillLeftPosition,
                  top: (widget.height - widget.indicatorHeight) / 2,
                  child: AnimatedBuilder(
                    animation: _scaleController,
                    builder: (context, child) {
                      // Apply the Scale Effect here
                      final double scale =
                          1.0 + (_scaleController.value * 0.15);
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: widget.indicatorWidth,
                          height: widget.indicatorHeight,
                          decoration: BoxDecoration(
                            color: indicatorCol,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // 4. The Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.icons.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onTabSelected(index),
                    child: Center(
                      child: Icon(
                        widget.icons[index],
                        size: widget.iconSize,
                        color: widget.selectedIndex == index
                            ? selVal
                            : unselVal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
