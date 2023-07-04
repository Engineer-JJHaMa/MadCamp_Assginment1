import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../style.dart';

class TwoButtons extends StatelessWidget {
  final VoidCallback bottomOnTap;
  final VoidCallback topOnTap;
  final Icon bottomIcon;
  final Icon topIcon;
  final String bottomLabel;
  final String topLabel;

  TwoButtons(
    this.bottomOnTap,
    this.topOnTap,
    this.bottomIcon,
    this.topIcon,
    this.bottomLabel,
    this.topLabel
  );

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      curve: Curves.bounceIn,
      backgroundColor: darkColor,
      gradient: floatingButtonGradient,
      gradientBoxShape: floatingButtonShape,
      childrenButtonSize: floatingButtonSize,
      children: [
        _TwoButtonsChild(bottomLabel, bottomIcon, bottomOnTap),
        _TwoButtonsChild(topLabel, topIcon, topOnTap),
      ],

    );
  }
}

SpeedDialChild _TwoButtonsChild(String label, Icon icon, VoidCallback onTap) {
  return SpeedDialChild(
    label: label,
    labelStyle: floatingButtonLabelStyle,
    labelBackgroundColor: mainColor,
    backgroundColor: mainColor,
    onTap: onTap,
    child: Container(
      width: floatingButtonSize.width,
      height: floatingButtonSize.height,
      decoration: BoxDecoration(
        shape: floatingButtonShape,
        gradient: floatingButtonGradient,
      ),
      child: icon,
    ),
  );
}