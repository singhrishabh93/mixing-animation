import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../painters/vinyl_disc_painter.dart';

class MixingScreen extends StatefulWidget {
  const MixingScreen({super.key});

  @override
  State<MixingScreen> createState() => _MixingScreenState();
}

class _MixingScreenState extends State<MixingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  bool _isAdvanced = false;

  static const _basicSize = 210.0;
  static const _advancedSize = 350.0;
  static const _toggleTopInStack = 140.0;
  static const _toggleHeight = 46.0;
  static const _toggleCenterY = _toggleTopInStack + _toggleHeight / 2;
  static const _discOffsetY = _toggleCenterY - _basicSize / 2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: _advancedSize / _basicSize,
    ).animate(curve);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: -math.pi,
    ).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabChanged(bool isAdvanced) {
    if (_isAdvanced == isAdvanced) return;
    setState(() => _isAdvanced = isAdvanced);
    if (isAdvanced) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D1B),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            _buildHeader(),
            Container(height: 24, color: const Color(0xFF0F0D1B)),
            Expanded(child: _buildDiscAndToggle()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2640),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          const Spacer(),
          Text(
            'Reset',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.8),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 108,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFE6545),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Save Mix',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscAndToggle() {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      children: [
        // Disc — clipped to top semicircle in local space;
        // rotation flips it to show as bottom semicircle in Advanced
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: const Offset(0, _discOffsetY),
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              ),
            );
          },
          child: SizedBox(
            width: _basicSize,
            height: _basicSize,
            child: ClipRect(
              clipper: const _TopHalfClipper(),
              child: CustomPaint(
                size: const Size(_basicSize, _basicSize),
                painter: VinylDiscPainter(),
              ),
            ),
          ),
        ),
        // Toggle
        Positioned(
          top: _toggleTopInStack,
          child: _buildToggle(),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0D1B),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Color.fromRGBO(254, 101, 69, 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem('Basic', !_isAdvanced),
          _buildToggleItem('Advanced', _isAdvanced),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isSelected) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabChanged(label == 'Advanced'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2A2640)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: isSelected
              ? Border.all(color: const Color(0xFFFE6545), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Color.fromRGBO(255, 255, 255, 0.5),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'Manrope',
          ),
        ),
      ),
    );
  }
}

class _TopHalfClipper extends CustomClipper<Rect> {
  const _TopHalfClipper();

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width, size.height / 2);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
