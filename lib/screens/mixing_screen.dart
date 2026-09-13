import 'dart:math' as math;
import 'dart:ui' as ui;
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
  late final Animation<double> _offsetYAnimation;
  late final Animation<double> _toggleYAnimation;
  bool _isAdvanced = false;

  static const _basicSize = 210.0;
  static const _advancedSize = 350.0;
  static const _basicToggleTop = 140.0;
  static const _advancedToggleTop = 25.0;
  static const _toggleHeight = 46.0;
  static const _basicDiscOffsetY = 33.0;
  // Mirror of Basic: toggle straddles the clip edge, disc extends below
  static const _advancedDiscOffsetY = -11.0;

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

    _offsetYAnimation = Tween<double>(
      begin: _basicDiscOffsetY,
      end: _advancedDiscOffsetY,
    ).animate(curve);

    _toggleYAnimation = Tween<double>(
      begin: _basicToggleTop,
      end: _advancedToggleTop,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          children: [
            Transform.translate(
              offset: Offset(0, _offsetYAnimation.value),
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SizedBox(
                    width: _basicSize,
                    height: _basicSize,
                    child: ClipRect(
                      clipper: const _TopHalfClipper(),
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return ui.Gradient.radial(
                            Offset(bounds.width * 0.52, bounds.height * 0.46),
                            bounds.width * 0.52,
                            [
                              Colors.white,
                              Colors.white,
                              Color.fromRGBO(255, 255, 255, 0.55),
                              Color.fromRGBO(255, 255, 255, 0.25),
                              Color.fromRGBO(255, 255, 255, 0.12),
                            ],
                            [0.0, 0.30, 0.58, 0.82, 1.0],
                          );
                        },
                        blendMode: BlendMode.dstIn,
                        child: child!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ..._buildOrbitalElements(
              _offsetYAnimation.value + _basicSize / 2,
              ((_controller.value - 0.5) * 2).clamp(0.0, 1.0),
            ),
            Positioned(
              top: _toggleYAnimation.value,
              child: _buildToggle(),
            ),
          ],
        );
      },
      child: CustomPaint(
        size: const Size(_basicSize, _basicSize),
        painter: VinylDiscPainter(),
      ),
    );
  }

  List<Widget> _buildOrbitalElements(double discCenterY, double opacity) {
    if (opacity <= 0) return [];

    const orbitR = 158.0;

    Widget at(double deg, double r, double size, Widget child) {
      final rad = deg * math.pi / 180;
      return Transform.translate(
        offset: Offset(
          r * math.sin(rad),
          discCenterY - r * math.cos(rad) - size / 2,
        ),
        child: Opacity(
          opacity: opacity,
          child: SizedBox(width: size, height: size, child: child),
        ),
      );
    }

    return [
      at(250, orbitR, 34, _iconCircle(Icons.graphic_eq)),
      at(218, orbitR, 34, _iconCircle(Icons.tune)),
      at(110, orbitR, 40, _imageCircle(
        const [Color(0xFF3A5F7A), Color(0xFF6B8FA3)],
      )),
      at(145, orbitR, 34, _imageCircle(
        const [Color(0xFFD4956B), Color(0xFF8B6B4A)],
      )),
      at(180, orbitR, 82, _activeCard()),
      Transform.translate(
        offset: Offset(0, discCenterY + orbitR + 60),
        child: Opacity(
          opacity: opacity,
          child: const Text(
            'Windy Evening Forest',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ),
    ];
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2A2640),
        border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.08)),
      ),
      child: Icon(icon, color: Color.fromRGBO(255, 255, 255, 0.5), size: 16),
    );
  }


  Widget _imageCircle(List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        border: Border.all(
          color: Color.fromRGBO(255, 255, 255, 0.15),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _activeCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A3D5C), Color(0xFFD4956B)],
        ),
        border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.1)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.black),
            ),
          ),
          const Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Text(
              '4/6',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
    return Rect.fromLTRB(0, 0, size.width, size.height * 0.65);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
