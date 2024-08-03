import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  CustomText(
    this.text, {
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style?.copyWith(fontFamily: 'Poppins') ?? TextStyle(fontFamily: 'Poppins'),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
