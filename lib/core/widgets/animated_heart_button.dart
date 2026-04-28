import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sahem/core/constants/app_colors.dart';

class AnimatedHeartButton extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback? onToggle;

  const AnimatedHeartButton({
    super.key,
    required this.isFavorited,
    this.onToggle,
  });

  @override
  State<AnimatedHeartButton> createState() => _AnimatedHeartButtonState();
}

class _AnimatedHeartButtonState extends State<AnimatedHeartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onToggle?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = _controller.value < 0.5
                ? 1.0 + (_controller.value * 0.6)
                : 1.3 - ((_controller.value - 0.5) * 0.6);
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Icon(
            widget.isFavorited ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: widget.isFavorited
                ? AppColors.heartActive
                : AppColors.heartInactive,
          ),
        ),
      ),
    );
  }
}
