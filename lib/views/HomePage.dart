import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habit_tracker/util/habit_tile.dart';
import 'package:habit_tracker/views/Statistics_page.dart'; // Assuming you have this file for the statistics page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List habitList = [
    ['Exercise', false, 0, 10, null],
    ['Read', false, 0, 20, null],
    ['Meditate', false, 0, 20, null],
    ['Code', false, 0, 40, null],
  ];

  void _toggleTimer(int index) {
    setState(() {
      if (habitList[index][1] == false && habitList[index][2] < habitList[index][3] * 60) {
        habitList[index][1] = true;
        habitList[index][4] = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            habitList[index][2] += 1;

            if (habitList[index][2] >= habitList[index][3] * 60) {
              timer.cancel();
              habitList[index][1] = false;
            }
          });
        });
      } else if (habitList[index][1] == true) {
        habitList[index][4]?.cancel();
        habitList[index][1] = false;
      }
    });
  }

  void _deleteHabit(int index) {
    setState(() {
      habitList.removeAt(index);
    });
  }

  void _addNewHabit() {
    String newHabitName = '';
    int newTimeGoal = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Habit Name'),
                onChanged: (value) {
                  newHabitName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Time Goal (minutes)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newTimeGoal = int.parse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  habitList.add([newHabitName, false, 0, newTimeGoal, null]);
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsMenu(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Habit'),
                onTap: () {
                  _deleteHabit(index);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(217, 242, 247, 1.0),
        title: Text(
          'Consistency is key.',
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => StatisticsPage(habitList: habitList),
              ));
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFF0288d1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: habitList.isEmpty
            ? Center(
          child: Text(
            'Add your habits',
            style: TextStyle(fontSize: 24, color: Colors.black54),
          ),
        )
            : ListView.builder(
          itemCount: habitList.length,
          itemBuilder: (context, index) {
            return HabitTile(
              habitName: habitList[index][0],
              onTap: () => _toggleTimer(index),
              settingsTapped: () => _showSettingsMenu(index),
              timeSpent: habitList[index][2],
              timeGoal: habitList[index][3],
              habitStarted: habitList[index][1],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewHabit,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
