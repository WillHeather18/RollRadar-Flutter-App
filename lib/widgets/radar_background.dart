import 'package:flutter/material.dart';

// RadarSweep widget
class RadarSweep extends StatefulWidget {
  final String imageUrl;
  final Duration duration;

  const RadarSweep({
    super.key,
    required this.imageUrl,
    this.duration = const Duration(seconds: 20),
  });

  @override
  State<RadarSweep> createState() => _RadarSweepState();
}

class _RadarSweepState extends State<RadarSweep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/radar_image.jpg'),
          fit: BoxFit.fitHeight,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: RadarSignal(controller: _controller),
    );
  }
}

class RadarSignal extends StatelessWidget {
  final AnimationController _controller;

  const RadarSignal({super.key, required AnimationController controller})
      : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.2, // Adjust this value to make the circle bigger or smaller
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 2.0).animate(_controller),
        child: Container(
          decoration: const BoxDecoration(
            gradient: SweepGradient(
              center: FractionalOffset.center,
              colors: [
                Colors.transparent,
                Color(0x8834A853),
                Colors.transparent
              ],
              stops: [0.15, 0.25, 0.26],
            ),
          ),
        ),
      ),
    );
  }
}
