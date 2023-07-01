// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';
import 'dart:ffi';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime _selectedDay = DateTime.now();

  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  final events = LinkedHashMap<DateTime, List<Event>> (
    equals: isSameDay,
    hashCode: getHashCode,
  );

  String eventsToJson () {
    const JsonEncoder encoder = JsonEncoder();

    Map<String, String> tmp = events.map((key, value) => 
      MapEntry(key.toString(), value.map((e) => e.zip()).join("\n")));
    final String jsonString = encoder.convert(tmp);
    debugPrint("encoded to: " + jsonString);
    return jsonString;
  }

  void jsonToEvents (String json) {
    const JsonDecoder decoder = JsonDecoder();

    Map<String, dynamic> tmp0 = decoder.convert(json);
    Map<String, String> tmp = tmp0.map((key, value) => MapEntry(key, value.toString()));
    tmp.forEach((k, v) => 
      debugPrint("key: " + k + ", value: " + v)
    );
    
    Map<DateTime, List<Event>> src = tmp.map((key, value) {
        return MapEntry(DateTime.parse(key), value.split("\n").map((z) => Event.unzip(z)).toList());
      }
    );
    debugPrint("decoded to :" + src.toString());
    events.clear();
    events.addAll(src);
  }

  Future<void> updatePreference() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('eventsjson', eventsToJson());
  }

  Future<void> getEventsFromPreference() async {
    var prefs = await SharedPreferences.getInstance();
    try{
      final json = prefs.getString('eventsjson') ?? '';
      debugPrint('call: ' + json);
      setState(() {
        jsonToEvents(json);
      });
      Future.delayed(Duration(seconds: 1), () {
        
        debugPrint("delay ends");
      });
      _selectedEvents.value = _getEventsForDay(_selectedDay);
      debugPrint("call finished");

    }catch(e){debugPrint('error: $e');}
  }

  @override
  void initState() {
    super.initState();
    getEventsFromPreference();
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    debugPrint("init finished");
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
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
    final json = eventsToJson();
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('eventsjson', json);
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _displayTextInputDialog(context, _selectedDay);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<DateTime>(
            valueListenable: _focusedDay,
            builder: (context, value, _) {
              return _CalendarHeader(
                focusedDay: value,
                onTodayButtonTap: () {
                  setState(() => _focusedDay.value = DateTime.now());
                },
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
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, val, _) {
                return ListView.builder(
                  itemCount: val.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: CheckboxListTile(
                        value: val[index].ischecked,
                        title: Text('${val[index]}'),
                        onChanged: (bool? value) {
                          setState(() {
                            val[index].ischecked = value ?? false;
                            updatePreference();
                          });
                        },
                        secondary: const Icon(Icons.hourglass_empty),
                        selected: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
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

// utils for calendar
// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.
/// Example event class.
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

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

TextEditingController _textFieldController = TextEditingController();

