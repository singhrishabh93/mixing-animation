import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../painters/vinyl_disc_painter.dart';

class _OrbitalItemData {
  final IconData? icon;
  final List<Color> colors;
  final bool isIcon;
  const _OrbitalItemData({this.icon, required this.colors, this.isIcon = false});
}

class MixingScreen extends StatefulWidget {
  const MixingScreen({super.key});

  @override
  State<MixingScreen> createState() => _MixingScreenState();
}

class _MixingScreenState extends State<MixingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _offsetYAnimation;
  late final Animation<double> _toggleYAnimation;
  bool _isAdvanced = false;

  late final AnimationController _orbitController;
  double _orbitFrom = 0.0;
  double _orbitTo = 0.0;
  Animation<double>? _orbitAnim;

  static const _basicSize = 210.0;
  static const _advancedSize = 350.0;
  static const _basicToggleTop = 140.0;
  static const _advancedToggleTop = 25.0;
  static const _toggleHeight = 46.0;
  static const _basicDiscOffsetY = 33.0;
  static const _advancedDiscOffsetY = -11.0;

  static const _orbitalItems = <_OrbitalItemData>[
    _OrbitalItemData(icon: Icons.waves, colors: [Color(0xFF2D4A5C), Color(0xFF4A8B7A)], isIcon: true),
    _OrbitalItemData(colors: [Color(0xFF3A5F7A), Color(0xFF6B8FA3)]),
    _OrbitalItemData(colors: [Color(0xFFD4956B), Color(0xFF8B6B4A)]),
    _OrbitalItemData(colors: [Color(0xFF2A3D5C), Color(0xFFD4956B)]),
    _OrbitalItemData(icon: Icons.tune, colors: [Color(0xFF4A3D6B), Color(0xFF8B6BA3)], isIcon: true),
    _OrbitalItemData(icon: Icons.graphic_eq, colors: [Color(0xFF2A5C3D), Color(0xFF6BD49B)], isIcon: true),
  ];

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

    _orbitController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _orbitController.dispose();
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

  void _onOrbitalItemTap(int index) {
    if (_orbitController.isAnimating) return;

    final currentAngle = (index * 45.0 + _orbitTo) % 360;
    var delta = (180.0 - currentAngle) % 360;
    
    if (delta > 180) {
      delta -= 360;
    } else if (delta < -180) {
      delta += 360;
    }
    
    if (delta.abs() < 1) return;

    _orbitFrom = _orbitTo;
    _orbitTo = _orbitTo + delta;

    _orbitController.duration = Duration(
      milliseconds: (600 + delta.abs() * 4.0).round().clamp(800, 2000),
    );
    _orbitAnim = Tween<double>(begin: _orbitFrom, end: _orbitTo).animate(
      CurvedAnimation(parent: _orbitController, curve: Curves.easeInOutCubic),
    );
    _orbitController.reset();
    _orbitController.forward();
  }

  double get _currentOrbitAngle {
    if (_orbitController.isAnimating) {
      return _orbitAnim?.value ?? _orbitTo;
    }
    return _orbitTo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D1B),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // In Basic mode, toggle center is at exactly 239.0 on the screen.
                  // The container top edge will slice perfectly through it horizontally.
                  final containerTop = 239.0 + (_controller.value * (430.0 - 239.0));
                  
                  return Stack(
                    children: [
                      // List Container with rounded top corners
                      Container(
                        margin: EdgeInsets.only(top: containerTop),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F0D1B),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(36),
                            topRight: Radius.circular(36),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(36),
                            topRight: Radius.circular(36),
                          ),
                          child: Stack(
                            children: [
                              // Background glows exactly starting from the horizontal line
                              AnimatedOpacity(
                                opacity: _isAdvanced ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 600),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 600,
                                      decoration: const BoxDecoration(
                                        gradient: RadialGradient(
                                          center: Alignment(-0.8, -1.0),
                                          radius: 1.2,
                                          colors: [
                                            Color(0xFFAA6FFF),
                                            Color.fromRGBO(64, 64, 101, 0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 600,
                                      decoration: const BoxDecoration(
                                        gradient: RadialGradient(
                                          center: Alignment(0.8, -1.0),
                                          radius: 1.2,
                                          colors: [
                                            Color(0xFFFE6545),
                                            Color.fromRGBO(64, 64, 101, 0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // The actual list content
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: _buildMixSections(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Top Elements over the container
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          _buildHeader(),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 450,
                            child: _buildDiscAndToggle(),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: SafeArea(child: _buildMiniPlayer()),
          ),
        ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        return AnimatedBuilder(
          animation: Listenable.merge([_controller, _orbitController]),
          builder: (context, child) {
            return Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
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
                  centerX,
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
      },
    );
  }

  List<Widget> _buildOrbitalElements(
      double centerX, double discCenterY, double opacity) {
    if (opacity <= 0) return [];

    const orbitR = 135.0;
    const activeSize = 82.0;
    const circleSize = 34.0;
    const imageCircleSize = 40.0;
    const morphRange = 50.0;
    const hitPadding = 10.0;

    final rotation = _currentOrbitAngle;
    final items = <Widget>[];

    for (int i = 0; i < _orbitalItems.length; i++) {
      final item = _orbitalItems[i];
      final baseDeg = i * 45.0;
      var currentDeg = (baseDeg + rotation) % 360;
      if (currentDeg < 0) currentDeg += 360;

      double posOpacity;
      if (currentDeg >= 115 && currentDeg <= 245) {
        posOpacity = 1.0;
      } else if (currentDeg > 85 && currentDeg < 115) {
        posOpacity = (currentDeg - 85) / 30;
      } else if (currentDeg > 245 && currentDeg < 275) {
        posOpacity = (275 - currentDeg) / 30;
      } else {
        posOpacity = 0.0;
      }

      final itemOpacity = posOpacity * opacity;
      if (itemOpacity <= 0.01) continue;

      final dist = (currentDeg - 180).abs();
      final altDist = 360 - dist;
      final minDist = math.min(dist, altDist);
      final morphFactor = (1.0 - minDist / morphRange).clamp(0.0, 1.0);

      final baseSize = item.isIcon ? circleSize : imageCircleSize;
      final size = baseSize + (activeSize - baseSize) * morphFactor;
      final borderRadius = size / 2 - (size / 2 - 16) * morphFactor;

      final rad = currentDeg * math.pi / 180;
      final px = centerX + orbitR * math.sin(rad) - size / 2;
      final py = discCenterY - orbitR * math.cos(rad) - size / 2;

      final tappable =
          morphFactor < 0.3 && _isAdvanced && !_orbitController.isAnimating;

      items.add(
        Positioned(
          left: px - hitPadding,
          top: py - hitPadding,
          width: size + hitPadding * 2,
          height: size + hitPadding * 2,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: tappable ? () => _onOrbitalItemTap(i) : null,
            child: Center(
              child: Opacity(
                opacity: itemOpacity,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: _buildOrbitalItem(i, morphFactor, borderRadius),
                ),
              ),
            ),
          ),
        ),
      );
    }

    items.add(
      Positioned(
        left: 0,
        right: 0,
        top: discCenterY + orbitR + 50,
        child: Opacity(
          opacity: opacity,
          child: const Text(
            'Windy Evening Forest',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ),
    );

    return items;
  }

  Widget _buildOrbitalItem(int index, double morphFactor, double borderRadius) {
    final item = _orbitalItems[index];

    return Stack(
      children: [
        if (item.isIcon)
          Opacity(
            opacity: (1.0 - morphFactor * 2).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: const Color(0xFF2A2640),
                border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.08)),
              ),
              child: Center(
                child: Icon(item.icon, color: Color.fromRGBO(255, 255, 255, 0.5), size: 16),
              ),
            ),
          ),
        Opacity(
          opacity: item.isIcon ? morphFactor.clamp(0.0, 1.0) : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: item.colors,
              ),
              border: Border.all(
                color: Color.fromRGBO(255, 255, 255, morphFactor > 0.5 ? 0.1 : 0.15),
                width: morphFactor > 0.5 ? 1 : 1.5,
              ),
            ),
          ),
        ),
        if (morphFactor > 0.5)
          Opacity(
            opacity: ((morphFactor - 0.5) * 2).clamp(0.0, 1.0),
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
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Text(
                    '${index + 1}/${_orbitalItems.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildMixSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Dwellspring Mixes'),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildMixCard(title: "Distant\nThunderstorm", volume: "22%", hasImage: true),
              _buildMixCard(title: "Windy Evening\nForest", volume: "92%", hasImage: true, fullPurpleFill: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('My Mixes'),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildMixCard(title: "Train sleep\nRide", volume: "12%"),
              _buildMixCard(title: "Sleep Ride\nwith Train", volume: "61%", fullPurpleFill: true),
              _buildMixCard(title: "Sleep Ride\nwith Bus", volume: "82%", fullPurpleFill: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('My Noises'),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildMixCard(title: "White noise\nCustomise...", volume: "31%", fullPurpleFill: true),
              _buildMixCard(title: "Brown noise", volume: "12%"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Manrope',
            ),
          ),
          const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildMixCard({
    required String title,
    required String volume,
    bool hasImage = false,
    bool fullPurpleFill = false,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12, top: 12, bottom: 12, left: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1D1934),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                if (hasImage)
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 42),
                    child: const Icon(Icons.image, color: Colors.white54, size: 24),
                  )
                else
                  const Icon(Icons.graphic_eq, color: Colors.white, size: 32),
                
                const SizedBox(height: 12),
                Expanded(
                  child: fullPurpleFill 
                    ? Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFC49BFF),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          )
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          title, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Manrope'),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          title, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Manrope'),
                        ),
                      ),
                ),
                if (!fullPurpleFill) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volume_up, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          volume,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D1934),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volume_up, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          volume,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: -8,
            left: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.black, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1934),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFFE6545), Color(0xFFAA6FFF)],
              ),
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F0D1B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.graphic_eq, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'My Mix',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pause, color: Colors.black),
          ),
        ],
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
