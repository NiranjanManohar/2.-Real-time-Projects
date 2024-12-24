import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  
import 'dart:async';  

class TimeViewerScreen extends StatefulWidget {
  @override
  _TimeViewerScreenState createState() => _TimeViewerScreenState();
}

class _TimeViewerScreenState extends State<TimeViewerScreen> {
  late String _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = _getFormattedTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getFormattedTime();
      });
    });
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return DateFormat('hh:mm:ss a').format(now); 
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Time Viewer',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(
            _currentTime,
            style: TextStyle(
              fontSize: 50.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono',
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
