import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_training_calendar2/sharedPreferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'menu.dart';



Future main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SimplePreferences.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'トレーニングカレンダー'),
    );
  }
}

class Event {
  final String title;

  Event({this.title});

  String toString() => this.title;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<DateTime, List<Event>> selectedEvents = {};
  CalendarFormat format = CalendarFormat.month;
  DateTime now = DateTime.now();
  DateTime selectedDay;
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedEvents = {};

    /// TableCalendarは日時までしかselectedDayに代入しない。
    /// DateTime.now()だと秒数まで代入してしまって、TableCalendarの想定する
    /// 日時とずれが生じて表示されなくなってしまう。
    selectedDay = DateTime.utc(now.year, now.month, now.day);
  }

  List<Event> _getEventsFromDay(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2022),
            calendarFormat: format,
            onFormatChanged: (CalendarFormat _format) {
              setState(() {
                format = _format;
              });
            },
            onDaySelected: (DateTime selectDay, DateTime focusDay) {
              setState(() {
                selectedDay = selectDay;
                focusedDay = focusDay;
              });
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDay, date);
            },
            eventLoader: _getEventsFromDay,
            rowHeight: 48,
            headerStyle: HeaderStyle(
                formatButtonShowsNext: false,
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonTextStyle: TextStyle(color: Colors.black)),
            calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueGrey,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
                todayTextStyle: TextStyle(color: Colors.black),
                todayDecoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                )),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsFromDay(selectedDay).length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: Text(
                              '削除する',
                              textAlign: TextAlign.center,
                            ),
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    child: SizedBox(
                                      width: 70,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'いいえ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    child: SizedBox(
                                      width: 70,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedEvents[selectedDay]
                                                .removeAt(index);
                                          });

                                          Navigator.pop(context);
                                        },
                                        child: Text('はい'),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        });
                  },
                  child: Card(

                    child: Container(
                      margin: EdgeInsets.all(8),
                      child: Text(
                        _getEventsFromDay(selectedDay)[index].title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return MenuPage(
                onSaved: (data) {
                  setState(() {
                    /// selectedEventsにselectedDayがあるかを確認
                    if (selectedEvents.containsKey(selectedDay)) {
                      /// あったらselectedDayの値（List<Event>）にdataを追加
                      selectedEvents[selectedDay].addAll(data);
                    } else {
                      /// なかったらselectedDayとdataをセットで追加。
                      ///　値の型に合わせてリストの形でdataを追加する。
                      selectedEvents.addAll({
                        selectedDay: data
                      });
                    }
                  });
                },
              );
            },
          ));
        },
        label: Text('トレーニングを追加'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
