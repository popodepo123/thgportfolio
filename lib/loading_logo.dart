import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:thgportfolio/theme.dart';

class LoadingLogo extends StatefulWidget {
  const LoadingLogo({super.key, this.speedMs = 300, this.size = 300});
  final int speedMs;
  final double size;

  @override
  State<LoadingLogo> createState() => _LoadingLogoState();
}

class _LoadingLogoState extends State<LoadingLogo>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  late Widget logo;
  Timer? _letterTimer;

  void start() {
    var phase = 0;
    _letterTimer = Timer.periodic(Duration(milliseconds: widget.speedMs * 3), (
      _,
    ) {
      if (!mounted) return;
      phase = (phase + 1) % 4;
      if (phase == 3) return;
      setState(() {
        logo = switch (phase) {
          1 => LoadingLogoH(
            fullStickDurationMs: widget.speedMs,
            size: widget.size,
          ),
          2 => LoadingLogoG(
            fullStickDurationMs: widget.speedMs,
            size: widget.size,
          ),
          _ => LoadingLogoT(
            fullStickDurationMs: widget.speedMs,
            size: widget.size,
          ),
        };
      });
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 360,
      duration: Duration(milliseconds: widget.speedMs * 20),
    );
    logo = LoadingLogoT(size: widget.size);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      start();
      animationController?.repeat();
      animationController?.addListener(() {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _letterTimer?.cancel();
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        // borderRadius: BorderRadiusGeometry.circular(widget.size),
      ),
      width: widget.size * 2,
      height: widget.size * 2,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(widget.size * .5),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(widget.size * .125),
            ),
            child: logo,
          ),
          Transform.rotate(
            angle: (math.pi / 180) * (animationController?.value ?? 0),
            child: Container(
              alignment: Alignment.center,
              width: widget.size * 2,
              height: widget.size * 2,
              decoration: BoxDecoration(
                border: Border.all(color: gruberYellow, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingLogoT extends StatefulWidget {
  const LoadingLogoT({
    super.key,
    this.fullStickDurationMs = 500,
    this.size = 100,
  });
  final double size;
  final int fullStickDurationMs;

  @override
  State<LoadingLogoT> createState() => _LoadingLogoTState();
}

class _LoadingLogoTState extends State<LoadingLogoT> {
  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        children: [
          Align(
            alignment: Alignment(0, 0),
            child: AnimatedStick(
              length: s,
              thickness: s * .125,
              axis: Axis.vertical,
              duration: Duration(milliseconds: widget.fullStickDurationMs),
              delay: Duration(
                milliseconds: (widget.fullStickDurationMs * .6).toInt(),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, -1),
            child: AnimatedStick(
              length: s,
              thickness: s * .125,
              axis: Axis.horizontal,
              duration: Duration(milliseconds: widget.fullStickDurationMs),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingLogoH extends StatefulWidget {
  const LoadingLogoH({
    super.key,
    this.fullStickDurationMs = 500,
    this.size = 100,
  });
  final double size;
  final int fullStickDurationMs;

  @override
  State<LoadingLogoH> createState() => _LoadingLogoHState();
}

class _LoadingLogoHState extends State<LoadingLogoH> {
  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        children: [
          Align(
            alignment: Alignment(-1, 0),
            child: AnimatedStick(
              length: s,
              thickness: s * .125,
              axis: Axis.vertical,
              duration: Duration(milliseconds: widget.fullStickDurationMs),
            ),
          ),
          Align(
            alignment: Alignment(1, 0),
            child: Column(
              children: [
                RotatedBox(
                  quarterTurns: 2,
                  child: AnimatedStick(
                    length: s / 2,
                    thickness: s * .125,
                    axis: Axis.vertical,
                    duration: Duration(
                      milliseconds: (widget.fullStickDurationMs / 2).toInt(),
                    ),
                    delay: Duration(
                      milliseconds: (widget.fullStickDurationMs * 1.6).toInt(),
                    ),
                  ),
                ),
                AnimatedStick(
                  length: s / 2,
                  thickness: s * .125,
                  axis: Axis.vertical,
                  duration: Duration(
                    milliseconds: (widget.fullStickDurationMs / 2).toInt(),
                  ),
                  delay: Duration(
                    milliseconds: (widget.fullStickDurationMs * 1.6).toInt(),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment(0, 0),
            child: AnimatedStick(
              length: s,
              thickness: s * .125,
              axis: Axis.horizontal,
              duration: Duration(milliseconds: widget.fullStickDurationMs),
              delay: Duration(
                milliseconds: (widget.fullStickDurationMs * 0.6).toInt(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingLogoG extends StatefulWidget {
  const LoadingLogoG({
    super.key,
    this.fullStickDurationMs = 500,
    this.size = 100,
  });
  final double size;
  final int fullStickDurationMs;

  @override
  State<LoadingLogoG> createState() => _LoadingLogoGState();
}

class _LoadingLogoGState extends State<LoadingLogoG> {
  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        children: [
          Align(
            alignment: Alignment(-1, 0),
            child: AnimatedStick(
              length: s,
              thickness: s * .125,
              axis: Axis.vertical,
              duration: Duration(milliseconds: widget.fullStickDurationMs),
            ),
          ),
          Align(
            alignment: Alignment(1, 1),
            child: RotatedBox(
              quarterTurns: 2,
              child: AnimatedStick(
                length: s / 2,
                thickness: s * .125,
                axis: Axis.vertical,
                duration: Duration(
                  milliseconds: (widget.fullStickDurationMs / 2).toInt(),
                ),
                delay: Duration(milliseconds: widget.fullStickDurationMs * 2),
              ),
            ),
          ),
          Align(
            alignment: Alignment(1, 0),
            child: RotatedBox(
              quarterTurns: 2,
              child: AnimatedStick(
                length: s / 2,
                thickness: s * .125,
                axis: Axis.horizontal,
                duration: Duration(
                  milliseconds: (widget.fullStickDurationMs / 2).toInt(),
                ),
                delay: Duration(
                  milliseconds: (widget.fullStickDurationMs * 2.5).toInt(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, 1),
            child: AnimatedStick(
              length: s,
              thickness: s * .125,
              axis: Axis.horizontal,
              duration: Duration(milliseconds: widget.fullStickDurationMs),
              delay: Duration(milliseconds: widget.fullStickDurationMs),
            ),
          ),
          Align(
            alignment: Alignment(0, -1),
            child: AnimatedStick(
              length: s,
              thickness: s * .125,
              axis: Axis.horizontal,
              duration: Duration(milliseconds: widget.fullStickDurationMs),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedStick extends StatefulWidget {
  final double length;
  final double thickness;
  final Axis axis;
  final Duration delay;
  final Duration duration;
  const AnimatedStick({
    super.key,
    required this.length,
    required this.thickness,
    required this.axis,
    this.delay = const Duration(milliseconds: 0),
    required this.duration,
  });

  @override
  State<AnimatedStick> createState() => _AnimatedStickState();
}

class _AnimatedStickState extends State<AnimatedStick>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Timer? _delayTimer;

  void start(AnimationController controller) {
    void forward() {
      if (mounted) controller.forward();
    }

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    if (widget.delay == Duration.zero) {
      forward();
    } else {
      _delayTimer = Timer(widget.delay, forward);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted && controller != null) start(controller!);
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllerVaue = controller?.value ?? 0;
    return SizedBox(
      width: switch (widget.axis) {
        Axis.horizontal => widget.length,
        Axis.vertical => widget.thickness,
      },
      height: switch (widget.axis) {
        Axis.horizontal => widget.thickness,
        Axis.vertical => widget.length,
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: switch (widget.axis) {
              Axis.horizontal => widget.length,
              Axis.vertical => widget.thickness,
            },
            height: switch (widget.axis) {
              Axis.horizontal => widget.thickness,
              Axis.vertical => widget.length,
            },
          ),
          Align(
            alignment: Alignment(
              switch (widget.axis) {
                Axis.horizontal => -1,
                Axis.vertical => 0,
              },
              switch (widget.axis) {
                Axis.horizontal => 0,
                Axis.vertical => -1,
              },
            ),
            child: Container(
              decoration: const BoxDecoration(color: gruberYellow),
              height: switch (widget.axis) {
                Axis.horizontal => widget.thickness,
                Axis.vertical => widget.length * controllerVaue,
              },
              width: switch (widget.axis) {
                Axis.vertical => widget.thickness,
                Axis.horizontal => widget.length * controllerVaue,
              },
            ),
          ),
        ],
      ),
    );
  }
}
