import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:poc_wgj/constants.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SpinKitSpinningLines(
      color: AppColors.primaryColor,
      size: 100.0,
    );
  }
}
