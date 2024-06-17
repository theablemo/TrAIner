import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CountdownIndicator extends StatefulWidget {
  final int countdown;
  final VoidCallback onCountdownComplete;

  CountdownIndicator(
      {required this.countdown, required this.onCountdownComplete});

  @override
  _CountdownIndicatorState createState() => _CountdownIndicatorState();
}

class _CountdownIndicatorState extends State<CountdownIndicator> {
  late int _currentCountdown;

  @override
  void initState() {
    super.initState();
    _currentCountdown = widget.countdown;
    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentCountdown > 0) {
        setState(() {
          _currentCountdown--;
        });
      } else {
        timer.cancel();
        widget.onCountdownComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularPercentIndicator(
          radius: 100.0,
          lineWidth: 10.0,
          percent: _currentCountdown / widget.countdown,
          center: Text(
            '$_currentCountdown',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          progressColor: Colors.blue,
        ),
      ],
    );
  }
}
