import 'package:flutter/material.dart';

const mainColor   = Color(0xFF8196D0);
const subColor    = Color(0xFFCB90BF);
const lightColor  = Color(0xFFD2DCF7);
const darkColor   = Color(0xFF353866);

const floatingButtonShape = BoxShape.circle;
const floatingButtonSize = Size(56, 56);
const floatingButtonGradient = LinearGradient(
  colors: [mainColor, subColor],
  stops: [0, 0.75],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
const floatingButtonLabelStyle = TextStyle(
  fontWeight: FontWeight.w500,
  color: lightColor,
  fontSize: 13.0
);
