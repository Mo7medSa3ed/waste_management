import 'package:flutter/material.dart';
import 'package:waset_management/constants.dart';

class PrimaryText extends StatelessWidget {
  const PrimaryText({
    Key? key,
    @required this.text,
    this.textAlign = TextAlign.start,
    this.color = kblack,
    this.fontSizeRatio = 1,
    this.maxlines,
    this.overflow,
    this.textStyle,
    this.fontWeight = FontWeight.normal,
  }) : super(key: key);
  final String? text;
  final TextAlign? textAlign;
  final double fontSizeRatio;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxlines;
  final TextOverflow? overflow;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      textAlign: textAlign,
      maxLines: maxlines,
      overflow: overflow,
      style: textStyle ??
          TextStyle(
              color: color ?? kprimary,
              fontSize: kdefaultTextSize * fontSizeRatio,
              fontWeight: fontWeight ?? FontWeight.bold),
    );
  }
}
