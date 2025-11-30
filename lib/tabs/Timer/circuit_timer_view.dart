import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'timer_utils.dart'; // FOR THE LOGIC THAT HANDLE THE TYPES OF TIMERS 
import 'Timer.dart'; // FOR THE TOP BAR THAT HAVE THE TYPES 
import 'dart:async';

class CircuitTimerView extends StatefulWidget {
  const CircuitTimerView({super.key});

  @override
  State<CircuitTimerView> createState() => _CircuitTimerViewState();
}

class _CircuitTimerViewState extends State<CircuitTimerView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Text("CircuitTimerView"),

      ),
    ); 
  }


}