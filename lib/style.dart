import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


const mainColor   = Color(0xFF8196D0);
const subColor    = Color(0xFFCB90BF);
const lightColor  = Color(0xFFD2DCF7);
const darkColor   = Color(0xFF353866);
const subColorHalfOpacity = Color.fromRGBO(0xCB, 0x90, 0xBF, 0.5);

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

const calenderStyle = CalendarStyle(
  holidayDecoration: BoxDecoration(
    border: Border.fromBorderSide(
      BorderSide(color: subColor, width: 1.4),
    ),
    shape: BoxShape.circle,
  ),
  holidayTextStyle: TextStyle(color: subColor),
  selectedDecoration: BoxDecoration(
    color: subColor,
    shape: BoxShape.circle,
  ),
  todayDecoration: BoxDecoration(
    color: subColorHalfOpacity,
    shape: BoxShape.circle,
  ),
  markerDecoration: BoxDecoration(
    color: darkColor,
    shape: BoxShape.circle,
  ),
);
const weatherPadding = EdgeInsets.fromLTRB(0, 10, 0, 10);
const listTileSize = 25.0;
const listTileEdge = EdgeInsets.all(3);
const listTilePadding = EdgeInsets.all(10);