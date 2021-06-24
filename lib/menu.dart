import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_training_calendar2/main.dart';
import 'package:flutter_training_calendar2/sharedPreferences.dart';

class MenuPage extends StatefulWidget {
  final void Function(List<Event>) onSaved;

  MenuPage({
    @required this.onSaved,
  });

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  TextEditingController controller;

  List<String> trainingMenu = [];
  String menu = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: menu);

    trainingMenu = SimplePreferences.getMenu() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('メニュー'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: '保存せずに戻る',
          icon: Icon(Icons.arrow_back_outlined),
          onPressed: () async {
            await SimplePreferences.setMenu(trainingMenu);
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              tooltip: '保存する',
              icon: Icon(Icons.save_alt_sharp),
              onPressed: () async {
                await SimplePreferences.setMenu(trainingMenu);
                final eventList =
                    trainingMenu.map((e) => Event(title: e)).toList();
                widget.onSaved(eventList);
                Navigator.pop(context);
              })
        ],
      ),
      body: ListView.builder(
        itemExtent: 50,
        itemCount: trainingMenu.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text(
                        '削除しますか？',
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
                                      trainingMenu.removeAt(index);
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
              child: Text(
                trainingMenu[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                    height: 1.75, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Text(
                    'メニューを追加',
                    textAlign: TextAlign.center,
                  ),
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: TextFormField(
                        controller: controller,
                        onChanged: (text) {
                          menu = text;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          child: ElevatedButton(
                            child: Text('はい'),
                            onPressed: () {
                              setState(() {
                                trainingMenu.add(menu);
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          child: ElevatedButton(
                            child: Text('いいえ'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
