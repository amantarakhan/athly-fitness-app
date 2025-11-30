import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'Timer.dart';


class IntervalTimerView extends StatefulWidget {
  const IntervalTimerView({super.key});

  @override
  State<IntervalTimerView> createState() => _IntervalTimerViewState();
}

class _IntervalTimerViewState extends State<IntervalTimerView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Text("IntervalTimerView"),

      ),
    ); 
  }
}