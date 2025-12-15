import 'package:flutter/material.dart';

class BatteryBar extends StatelessWidget {
  final int percentage;
  BatteryBar({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        children: [
          Container(
            width: 2 * percentage.toDouble(),
            decoration: BoxDecoration(
              color: percentage < 20 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Center(
            child: Text('$percentage%', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
