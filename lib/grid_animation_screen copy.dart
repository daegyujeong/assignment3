import 'package:flutter/material.dart';
import 'dart:math' as math;

class GridAnimationScreen extends StatefulWidget {
  const GridAnimationScreen({super.key});

  @override
  State<GridAnimationScreen> createState() => _GridAnimationScreenState();
}

class _GridAnimationScreenState extends State<GridAnimationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration:
        const Duration(milliseconds: 1500), // Even faster overall animation
  )..addListener(() {
      setState(() {});
    });

  // Animation sequences for Z pattern
  late final Animation<double> _sequence1 = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeInOut),
    ),
  );

  late final Animation<double> _sequence2 = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.4, curve: Curves.easeInOut),
    ),
  );

  late final Animation<double> _sequence3 = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 0.6, curve: Curves.easeInOut),
    ),
  );

  late final Animation<double> _sequence4 = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 0.8, curve: Curves.easeInOut),
    ),
  );

  late final Animation<double> _sequence5 = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
    ),
  );

  final ValueNotifier<double> _range = ValueNotifier(0.0);

  void _play() {
    _animationController.forward(from: 0.0);
  }

  void _pause() {
    _animationController.stop();
  }

  void _rewind() {
    _animationController.reverse(from: 1); // Starting from 2.0 instead of 1.0
  }

  bool _looping = false;

  void _toggleLooping() {
    if (_looping) {
      _animationController.stop();
    } else {
      // Start the continuous reverse animation
      _animationController.value = 1; // Set to the end value
      _animationController.reverse(); // Start the first reverse

      // Set up a listener to restart from 2.0 when it reaches 0.0
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // This happens when forward animation completes (at value 2.0)
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          // This happens when reverse animation completes (at value 0.0)
          _animationController.value = 1; // Jump to end
          _animationController.reverse(); // Start reverse again
        }
      });
    }
    setState(() {
      _looping = !_looping;
    });
  }

  void _onChanged(double value) {
    _animationController.value =
        value; // Scale up from slider's 0-1 range to controller's 0-2 range
    _range.value = value;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController.addListener(() {
      _range.value =
          _animationController.value; // Scale down to 0-1 range for slider
    });
  }

  // Check if a specific square should be lit based on its position and current animation state
  bool isSquareLit(int row, int col) {
    // First sequence - Top row lights
    if (_sequence1.value > 0 && _sequence1.value < 1) {
      if ((_sequence1.value * 5).toInt() % 5 == col && row == 0) {
        return true;
      }
      return false;
    }
    if (_sequence2.value > 0 && _sequence2.value < 1) {
      if ((_sequence2.value * 5).toInt() % 5 == col && row == 1) {
        return true;
      }
      return false;
    }

    if (_sequence3.value > 0 && _sequence3.value < 1) {
      if ((_sequence3.value * 5).toInt() % 5 == col && row == 2) {
        return true;
      }
      return false;
    }
    if (_sequence4.value > 0 && _sequence4.value < 1) {
      if ((_sequence4.value * 5).toInt() % 5 == col && row == 3) {
        return true;
      }
      return false;
    }
    if (_sequence5.value > 0 && _sequence5.value < 1) {
      if ((_sequence5.value * 5).toInt() % 5 == col && row == 4) {
        return true;
      }
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid Animation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Grid of squares
            Container(
              width: 300,
              height: 300,
              color: Colors.black,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 25,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final row = index ~/ 5;
                  final col = index % 5;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isSquareLit(row, col)
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color.fromARGB(255, 255, 0, 0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _play,
                  child: const Text("Play"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pause,
                  child: const Text("Pause"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _rewind,
                  child: const Text("Rewind"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _toggleLooping,
                  child: Text(
                    _looping ? "Stop looping" : "Start looping",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Animation slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ValueListenableBuilder(
                valueListenable: _range,
                builder: (context, value, child) {
                  return Slider(
                    value: value,
                    onChanged: _onChanged,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
