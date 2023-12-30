import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pausable_timer/pausable_timer.dart';

class FlashingSquareState extends State {

  bool show = true;
  bool play = false;
  late PausableTimer t;


  Timer createTimer() {
    return Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        show = !show;
      });
     });
  }

  PausableTimer createPausableTimer() {
    return PausableTimer.periodic(Duration(seconds: 1), () { 
      setState(() {
        show = !show;
      });
    });
  }

  bool _onKey(KeyEvent ke) {

    final key = ke.logicalKey.keyLabel;

    // print(ke.logicalKey);

    if (ke is KeyDownEvent) {
      print("not keydown");
      return false;
    }
    
    if (key == "B") {
      setState(() {
        if (play) {
          print("pausing");
          t.pause();
          setState(() {
            play = false;
          });
        } else {
          print("playing");
          t.start();
          setState(() {
            play = true;
          });
        }
      });
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    show = true;
    t = createPausableTimer();
    t.start();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  Widget build(BuildContext context) {
    return show ? Container(
      height: 10,
      width: 10,
      
      decoration: BoxDecoration(color: Colors.red, ),
    ) : Container();

  }

}

class FlashingSquare extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FlashingSquareState();
  }

}