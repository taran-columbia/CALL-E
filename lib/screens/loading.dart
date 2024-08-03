// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:poc_wgj/constants.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {


void setup() async {
  Future.delayed(const Duration(seconds: 3), () {
    Navigator.pushReplacementNamed(context, '/');
  });
    
    
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SpinKitFoldingCube(
              color: Colors.white,
              size: 100.0,
            ),
            Container(
              margin: const EdgeInsets.only(top: 30.0),
              child: const Text(
              'CALL-E',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                fontFamily: AppColors.fontFamily
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}