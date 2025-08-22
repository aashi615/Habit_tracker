import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewProgressScreen extends StatefulWidget {
  const ViewProgressScreen({super.key});

  @override
  State<ViewProgressScreen> createState() => _ViewProgressScreenState();
}

class _ViewProgressScreenState extends State<ViewProgressScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  Map<String, Map<DateTime, bool>> habitProgressMap = {};
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchAllHabitsAndProgress();
  }

  Future<void> fetchAllHabitsAndProgress() async {
    final habitCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('daily_habits')
        .collection('habits');

    final habitsSnapshot = await habitCollection.get();

    Map<String, Map<DateTime, bool>> tempHabitMap = {};

    for (var habitDoc in habitsSnapshot.docs) {
      final habitName = habitDoc.id;

      final progressSnapshot =
      await habitCollection.doc(habitName).collection('progress').get();

      Map<DateTime, bool> progressMap = {};

      for (var progressDoc in progressSnapshot.docs) {
        try {
          List<String> parts = progressDoc.id.split('-');
          int year = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int day = int.parse(parts[2]);
          DateTime date = DateTime(year, month, day);

          bool isDone = progressDoc['isDone'] ?? false;
          progressMap[DateTime(date.year, date.month, date.day)] = isDone;
        } catch (e) {
          debugPrint('Error parsing date for ${progressDoc.id}: $e');
        }
      }

      tempHabitMap[habitName] = progressMap;
    }

    setState(() {
      habitProgressMap = tempHabitMap;
    });
  }

  Color getDayColor(String habitName, DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final progressMap = habitProgressMap[habitName];
    if (progressMap != null && progressMap.containsKey(key)) {
      return progressMap[key]! ? Colors.green : Colors.red;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("My Progress"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDDDE6), Color(0xFF6A82FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: habitProgressMap.isEmpty
            ? const Center(child: CircularProgressIndicator())
            :SafeArea(

              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          itemCount: habitProgressMap.length,
                          itemBuilder: (context, index) {
                String habitName = habitProgressMap.keys.elementAt(index);

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habitName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TableCalendar(
                        firstDay: DateTime.utc(2023, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.month,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        calendarStyle: const CalendarStyle(
                          weekendTextStyle: TextStyle(color: Colors.black54),
                          defaultTextStyle: TextStyle(color: Colors.black87),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, _) {
                            return Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: getDayColor(habitName, day),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },
                          todayBuilder: (context, day, _) {
                            return Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: getDayColor(habitName, day),
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
                          },
                        ),
              ),
            ),
      ),
    );
  }
}
