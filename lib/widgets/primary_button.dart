import 'package:flutter/material.dart';
import 'package:waset_management/constants.dart';
import 'package:waset_management/widgets/primary_text.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {Key? key,
      @required this.text,
      this.icon,
      this.color = kprimary,
      this.hasIcon = false,
      this.outline = false,
      @required this.onTap})
      : super(key: key);
  final String? text;
  final IconData? icon;
  final Color? color;
  final bool? hasIcon;
  final bool? outline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        )),
        tapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: MaterialStateProperty.all(color),
        padding: MaterialStateProperty.all(
            const EdgeInsets.all(kdefultPadding / 1.2)),
      ),
      child: PrimaryText(
        text: text ?? '',
        textAlign: TextAlign.center,
        color: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      ),
    );
  }
}
