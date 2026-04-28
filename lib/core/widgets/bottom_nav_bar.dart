import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sahem/core/constants/app_colors.dart';
import 'package:sahem/core/router/app_router.dart';

// ── Public widget ──────────────────────────────────────────────────────────

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  static const _items = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItemData(
      icon: Icons.search_outlined,
      activeIcon: Icons.search_rounded,
      label: 'Search',
    ),
    _NavItemData(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite_rounded,
      label: 'Saved',
    ),
  ];

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.search);
        break;
      case 2:
        context.go(AppRoutes.favorites);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _LiquidNavBar(
      items: _items,
      currentIndex: currentIndex,
      onTap: (i) => _onTap(context, i),
    );
  }
}

// ── Internal data class ────────────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ── Core liquid nav bar ────────────────────────────────────────────────────

class _LiquidNavBar extends StatefulWidget {
  final List<_NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _LiquidNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_LiquidNavBar> createState() => _LiquidNavBarState();
}

class _LiquidNavBarState extends State<_LiquidNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blobX; // 0..1 normalised position
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    // Start at the correct position with no animation
    final start = _normalised(widget.currentIndex);
    _blobX = AlwaysStoppedAnimation<double>(start);
  }

  @override
  void didUpdateWidget(_LiquidNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      final from = _normalised(old.currentIndex);
      final to = _normalised(widget.currentIndex);
      _blobX = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
      );
      _controller.forward(from: 0);
      _previousIndex = old.currentIndex;
    }
  }

  double _normalised(int index) {
    final count = widget.items.length;
    return (index + 0.5) / count;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final totalHeight = 72.0 + bottom;

    return SizedBox(
      height: totalHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final blobPos = _blobX.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Wave surface ──────────────────────────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: _WavePainter(
                    blobX: blobPos,
                    color: AppColors.surface,
                    shadowColor: const Color(0x12000000),
                  ),
                ),
              ),

              // ── Floating active bubble ───────────────────────────
              _FloatingBubble(
                blobX: blobPos,
                totalHeight: totalHeight,
              ),

              // ── Nav items ────────────────────────────────────────
              Positioned(
                bottom: bottom,
                left: 0,
                right: 0,
                height: 72,
                child: Row(
                  children: List.generate(widget.items.length, (index) {
                    return Expanded(
                      child: _NavItemWidget(
                        data: widget.items[index],
                        isActive: widget.currentIndex == index,
                        blobX: blobPos,
                        index: index,
                        count: widget.items.length,
                        onTap: () => widget.onTap(index),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Floating amber circle that rises above the wave ────────────────────────

class _FloatingBubble extends StatelessWidget {
  final double blobX; // 0..1
  final double totalHeight;

  const _FloatingBubble({required this.blobX, required this.totalHeight});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cx = blobX * width;
    const bubbleSize = 52.0;
    const riseOffset = 28.0;

    return Positioned(
      left: cx - bubbleSize / 2,
      top: -riseOffset,
      child: Container(
        width: bubbleSize,
        height: bubbleSize,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Individual nav item with rising icon behaviour ─────────────────────────

class _NavItemWidget extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final double blobX; // 0..1 current blob position
  final int index;
  final int count;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.data,
    required this.isActive,
    required this.blobX,
    required this.index,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // How close is the blob to this item? 0 = exact, 1 = far away
    final itemCentre = (index + 0.5) / count;
    final proximity = (blobX - itemCentre).abs() * count;
    final rise = math.max(0.0, 1.0 - proximity).clamp(0.0, 1.0);

    // Icon rises upward as the blob approaches
    final iconOffset = -rise * 35.0;
    // Label fades in as blob settles
    final labelOpacity = (rise * 1.6 - 0.6).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Label anchored to bottom of bar
            Positioned(
              bottom: 8,
              child: Opacity(
                opacity: labelOpacity,
                child: Text(
                  data.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // Icon that floats up
            Transform.translate(
              offset: Offset(0, iconOffset),
              child: Icon(
                isActive ? data.activeIcon : data.icon,
                size: 22,
                color: rise > 0.5 ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CustomPainter — liquid wave with notch ─────────────────────────────────

class _WavePainter extends CustomPainter {
  final double blobX; // 0..1
  final Color color;
  final Color shadowColor;

  const _WavePainter({
    required this.blobX,
    required this.color,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = blobX * size.width;

    // ── Shadow ──────────────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(_buildPath(size, cx, offsetY: 2), shadowPaint);

    // ── Surface ─────────────────────────────────────────────────
    final fillPaint = Paint()..color = color;
    canvas.drawPath(_buildPath(size, cx), fillPaint);
  }

  Path _buildPath(Size size, double cx, {double offsetY = 0}) {
    const notchR = 34.0; // radius of the circular notch cut
    const notchDepth = 22.0; // how deep the wave dips
    const spreadW = 52.0; // horizontal spread of the notch shoulders

    final left = cx - spreadW;
    final right = cx + spreadW;
    final top = offsetY;

    final path = Path()
      ..moveTo(0, top)

      // Flat left section
      ..lineTo(left - 20, top)

      // Left shoulder curve
      ..cubicTo(
        left - 8,
        top,
        left,
        top + notchDepth * 0.55,
        cx - notchR * 0.65,
        top + notchDepth,
      )

      // Bottom arc of the notch
      ..cubicTo(
        cx - notchR * 0.2,
        top + notchDepth + 6,
        cx + notchR * 0.2,
        top + notchDepth + 6,
        cx + notchR * 0.65,
        top + notchDepth,
      )

      // Right shoulder curve
      ..cubicTo(
        right,
        top + notchDepth * 0.55,
        right + 8,
        top,
        right + 20,
        top,
      )

      // Flat right section → close
      ..lineTo(size.width, top)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.blobX != blobX || old.color != color;
}
