// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static const mainColor = Color.fromARGB(255, 149, 150, 208);
  static const subColor = Color.fromARGB(255, 203, 144, 191);
  static const lightColor = Color(0xFFF8FAFF);
  static const darkColor = Color(0xFF353866);
  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier(List.empty());
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final margin = const EdgeInsets.all(6);
  final padding = const EdgeInsets.all(0);
  final alignment = Alignment.center;
  final duration = const Duration(milliseconds: 250);

  final TextEditingController _textFieldController = TextEditingController();
  late PageController _pageController;
  

  final events = LinkedHashMap<DateTime, List<Event>> (
    equals: isSameDay,
    hashCode: (key) =>
      key.day * 1000000 + key.month * 10000 + key.year,
  );
  final weathers = LinkedHashMap<DateTime, String> (
    equals: isSameDay,
    hashCode: (key) =>
      key.day * 1000000 + key.month * 10000 + key.year,
  );

  @override
  void initState() {
    super.initState();
    _getEventsFromPreference();
    _getWeatherInfo(DateTime.now());
    // debugPrint("type of dotenv: " + dotenv.env.runtimeType.toString());
    // debugPrint('map: ' + dotenv.env.toString());
    // debugPrint('map: ' + dotenv.env['API_KEY'].toString());
    // debugPrint("init finished");
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightColor,
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          visible: true,
          curve: Curves.bounceIn,
          backgroundColor: darkColor,
          // childMargin: const EdgeInsets.all(0),
          gradient: LinearGradient(
            colors: [mainColor, subColor],
            stops: [0, 0.75],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          gradientBoxShape: BoxShape.circle,
          childrenButtonSize: Size(56, 56),
          children: [
            SpeedDialChild(
              // child: const Icon(Icons.add, color: lightColor),
              child: Container(
                width: 56,
                height: 56,
                // padding: EdgeInsets.all(0),
                child: const Icon(Icons.add, color: lightColor),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [mainColor, subColor],
                    stops: [0, 0.75],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              label: "일정 추가하기",
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: lightColor,
                  fontSize: 13.0),
              backgroundColor: mainColor,
              labelBackgroundColor: mainColor,
              onTap: () {
                _displayTextInputDialog(context, _selectedDay);
              },
            ),
            SpeedDialChild(
              child: Container(
                  width: 56,
                  height: 56,
                  // padding: EdgeInsets.all(0),
                  child: const Icon(Icons.remove, color: lightColor),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [mainColor, subColor],
                      stops: [0, 0.75],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              label: "일정 지우기",
              backgroundColor: mainColor,
              labelBackgroundColor: mainColor,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, color: lightColor, fontSize: 13.0),
              onTap: () {
                _displayRemovalDialog(context);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            ValueListenableBuilder<DateTime>(
              valueListenable: _focusedDay,
              builder: (context, value, _) {
                return _CalendarHeader(
                  focusedDay: value,
                  onLeftArrowTap: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  onRightArrowTap: () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                );
              },
            ),
            TableCalendar<Event>(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay.value,
              headerVisible: false,
              holidayPredicate: (DateTime day) {
                return ((day.weekday == 6) | (day.weekday == 7)) & (day.month == _focusedDay.value.month);
              },
              selectedDayPredicate: (day) {
                // Use `selectedDayPredicate` to determine which day is currently selected.
                // If this returns true, then `day` will be marked as selected.
                // Using `isSameDay` is recommended to disregard
                // the time-part of compared DateTime objects.
                return isSameDay(_selectedDay, day);
              },
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              onDaySelected: _onDaySelected,
              onCalendarCreated: (controller) => _pageController = controller,
              onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() => _calendarFormat = format);
                }
              },
              calendarStyle: CalendarStyle(
                holidayDecoration: const BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: subColor, width: 1.4),
                  ),
                  shape: BoxShape.circle,
                ),
                holidayTextStyle: const TextStyle(color: subColor),
                selectedDecoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //   colors: [mainColor, subColor],
                  //   stops: [0, 0.5],
                  // ),
                  color: subColor,
                  shape: BoxShape.circle,

                ),
                todayDecoration: BoxDecoration(
                  color: subColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: darkColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Visibility(
                child: Text("\u{1F324} 이날의 날씨는 " + (weathers[_selectedDay] ?? "") + " 입니다 \u{1F327}", textScaleFactor: 1.2,),
                visible: weathers[_selectedDay] != null,
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, val, _) {
                  return ListView.builder(
                    itemCount: val.length,
                    itemBuilder: (context, index) {
                      return Container(
                        // decoration: BoxDecoration(
                        //   border: Border.all(color: darkColor),
                        //   borderRadius: BorderRadius.circular(20),
                        // ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 0,
                        ),
                        child: GFCheckboxListTile(
                          value: val[index].ischecked,
                          titleText: val[index].toString(),
                          onChanged: (bool? value) {
                            setState(() {
                              val[index].ischecked = value ?? false;
                              _updatePreference();
                            });
                          },
                          size: 25,
                          margin: EdgeInsets.all(3),
                          padding: EdgeInsets.all(10),
                          color: lightColor,
                          activeBgColor: subColor,
                          activeBorderColor: lightColor,
                          inactiveBorderColor: lightColor,
                          type: GFCheckboxType.circle,
                          activeIcon: Icon(
                            Icons.check,
                            size: 16,
                            color: lightColor,
                          ),
                        ),
                        // child: CheckboxListTile(
                        //   value: val[index].ischecked,
                        //   title: Text('${val[index]}'),
                        //   onChanged: (bool? value) {
                        //     setState(() {
                        //       val[index].ischecked = value ?? false;
                        //       _updatePreference();
                        //     });
                        //   },
                        //   //secondary: const Icon(Icons.hourglass_empty),
                        //   selected: true,
                        // ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }

  String _eventsToJson () {
    const JsonEncoder encoder = JsonEncoder();

    Map<String, String> tmp = events.map((key, value) => 
      MapEntry(key.toString(), value.map((e) => e.zip()).join("\n")));
    final String jsonString = encoder.convert(tmp);
    //debugPrint("encoded to: " + jsonString);
    return jsonString;
  }

  void _jsonToEvents (String json) {
    const JsonDecoder decoder = JsonDecoder();

    Map<String, dynamic> tmp0 = decoder.convert(json);
    Map<String, String> tmp = tmp0.map((key, value) => MapEntry(key, value.toString()));
    // tmp.forEach((k, v) => 
    //   debugPrint("key: " + k + ", value: " + v)
    // );
    Map<DateTime, List<Event>> src = tmp.map((key, value) {
        return MapEntry(DateTime.parse(key), value.split("\n").map((z) => Event.unzip(z)).toList());
      }
    );
    // debugPrint("decoded to :" + src.toString());
    events.clear();
    events.addAll(src);
  }

  Future<void> _updatePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('eventsjson', _eventsToJson());
  }

  Future<void> _getEventsFromPreference() async {
    var prefs = await SharedPreferences.getInstance();
    try{
      final json = prefs.getString('eventsjson') ?? '';
      debugPrint('call: ' + json);
      setState(() {
        _jsonToEvents(json);
      });
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    }catch(e){debugPrint('error: $e');}
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if(!isSameDay(_selectedDay, selectedDay)) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay.value = focusedDay;
        });
      }
    });
    _selectedEvents.value = _getEventsForDay(selectedDay);
  }

  Future<void> _onEventsCreated (DateTime day) async {
    print(_textFieldController.text);
    setState(() {
      if(events.containsKey(day)){
        events[day]?.add(Event(_textFieldController.text ?? 'empty string'));
      } else {
        events[day] = List.filled(1, Event(_textFieldController.text ?? 'empty string'), growable: true);
      }
      _selectedEvents.value = _getEventsForDay(day);
    });
    final json = _eventsToJson();
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('eventsjson', json);
    Navigator.pop(context);
  }

  Future<void> _onEventsRemoved(DateTime day) async {
    setState(() {
      if(events.containsKey(day)){
        debugPrint("removal start");
        events[day]?.removeWhere((e) => e.ischecked);
      }
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context, DateTime day) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add plan'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "type your plan"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () => _onEventsCreated(day),
            ),
          ],
        );
      },
    );
  }

  Future<void> _displayRemovalDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 지우기'),
        content: const Text('완료한 일정을 제거할까요?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _onEventsRemoved(_selectedDay);
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _getWeatherInfo(DateTime day) async {
    const JsonDecoder decoder = JsonDecoder();
    final Map<DateTime, String> weather = Map();
    final key = dotenv.env['API_KEY'] ?? 'APIkey is not found';
    debugPrint("key: " + key);
    const dataType = "JSON";
    const regId = "11C20000"; //대전, 세종, 충남으로 일단 고정
    final tmFc = day.year.toString()
    + day.month.toString().padLeft(2, '0')
    + day.day.toString().padLeft(2, '0');

    final urlShortWeather = Uri.https("apis.data.go.kr", "/1360000/VilageFcstInfoService_2.0/getVilageFcst", {
      "serviceKey": key,
      "numOfRows": "1000",
      "dataType": dataType,
      "base_date": tmFc,
      "base_time": "0500",
      "nx": "55",
      "ny": "127",
    });
    final urlMiddleWeather = Uri.https("apis.data.go.kr", "/1360000/MidFcstInfoService/getMidLandFcst", {
      "serviceKey": key,
      "dataType": dataType,
      "regId": regId,
      "tmFc": tmFc + "0600",
    });

    // debugPrint("url: " + url.toString());
    final http.Response responseShort = await http.get(urlShortWeather);
    final http.Response responseMiddle = await http.get(urlMiddleWeather);

    debugPrint('Response status: ${responseMiddle.statusCode}');
    debugPrint('Response body: ${responseMiddle.body}');

    final Map<String, dynamic> bodyShort = decoder.convert(responseShort  .body);
    final Map<String, dynamic> bodyMiddle = decoder.convert(responseMiddle.body);
    final List<dynamic> contentsShort = bodyShort["response"]["body"]["items"]["item"] ?? List.empty();
    final Map<String, dynamic> contentsMiddle = bodyMiddle["response"]["body"]["items"]["item"][0] ?? Map();
    debugPrint(contentsMiddle.toString());

    const [0, 1, 2].forEach((after) {
      final contentsShortFiltered = contentsShort.where((e) => 
        (e["fcstDate"] == day.year.toString()
          + day.month.toString().padLeft(2, '0')
          + (day.day + after).toString().padLeft(2, '0'))
        & (e["fcstTime"] == "0800")
        & ((e["category"] == "SKY")|(e["category"] == "PTY"))).toList();
      debugPrint(contentsShortFiltered.toString());

      weather[day.add(Duration(days: after))] = 
        weatherCode[int.parse(contentsShortFiltered[1]["fcstValue"])*10
          + int.parse(contentsShortFiltered[0]["fcstValue"])];
    });
    const [3, 4, 5, 6, 7].forEach((after) =>
      weather[day.add(Duration(days: after))] = contentsMiddle["wf" + after.toString() + "Am"]);
    const [8, 9, 10].forEach((after) =>
      weather[day.add(Duration(days: after))] = contentsMiddle["wf" + after.toString()]);
    weather.forEach((key, value) {
      debugPrint("k: "+key.toString()+"v: "+value.toString());
    });
    if(this.mounted){
      setState(() {
      weathers.clear();
      weathers.addAll(weather);
    });}
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: TextStyle(fontSize: 26.0),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}

class Event {
  late String title;
  late bool ischecked;

  Event(String title) {
    this.title = title;
    this.ischecked = false;
  }
  Event.unzip(String zipped) {
    final tmp = zipped.split('/');
    this.title = tmp[0];
    this.ischecked = (tmp[1] == 'true')?true:false;
  }

  @override
  String toString() => title;
  String zip() => title + "/" + ischecked.toString();
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

const List<String> weatherCode = [
  "", "맑음", "", "구름많음", "흐림",
  "", "맑고 비", "", "구름없고 비", "흐리고 비",
  "", "맑고 비/눈", "", "구름없고 비/눈", "흐리고 비/눈",
  "", "맑고 눈", "", "구름없고 눈", "흐리고 눈",
  "", "맑고 소나기", "", "구름없고 소나기", "흐리고 소나기",
];
