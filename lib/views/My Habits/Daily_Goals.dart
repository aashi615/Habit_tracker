import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/views/My%20Habits/Add_daily_habits.dart';

class DailyHabitsScreen extends StatefulWidget {
  const DailyHabitsScreen({super.key});

  @override
  State<DailyHabitsScreen> createState() => _DailyHabitsScreenState();
}

class _DailyHabitsScreenState extends State<DailyHabitsScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  Map<String, Timer?> timers = {};
  Map<String, String> timerMessages = {};

  Future<void> markHabitDone(String habitName) async {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('daily_habits')
        .collection('habits')
        .doc(habitName)
        .collection('progress')
        .doc(todayStr)
        .set({'isDone': true, 'timestamp': Timestamp.now()});
  }

  Future<void> unmarkHabitDone(String habitName) async {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('daily_habits')
        .collection('habits')
        .doc(habitName)
        .collection('progress')
        .doc(todayStr)
        .delete();
  }

  Future<bool> isHabitDone(String habitName) async {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('daily_habits')
        .collection('habits')
        .doc(habitName)
        .collection('progress')
        .doc(todayStr)
        .get();

    return doc.exists && doc.data()!['isDone'] == true;
  }

  void startTimerDialog(String habitName) async {
    final isDone = await isHabitDone(habitName);
    if (isDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ You have already completed this activity!"),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Set Timer (minutes)"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter minutes"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(controller.text);
              if (minutes != null && minutes > 0) {
                Navigator.pop(ctx);
                startTimer(habitName, Duration(minutes: minutes));
              }
            },
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }

  void startTimer(String habitName, Duration duration) {
    timers[habitName]?.cancel();
    setState(() {
      timerMessages[habitName] = "Timer started for ${duration.inMinutes} minutes";
    });
    timers[habitName] = Timer(duration, () async {
      await markHabitDone(habitName);
      setState(() {
        timerMessages[habitName] = "Timer ended! Habit marked as done.";
      });

      // Clear message after a few seconds
      Timer(const Duration(seconds: 3), () {
        setState(() {
          timerMessages.remove(habitName);
        });
      });
    });
    setState(() {});
  }

  Future<void> deleteHabitAndProgress(String habitName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Get references for habit and progress
    final habitRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('daily_habits')
        .collection('habits')
        .doc(habitName);

    final progressRef = habitRef.collection('progress');

    // Begin a batch operation
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      // Add the habit document deletion to the batch
      batch.delete(habitRef);

      // Get all progress documents and add deletion to the batch
      final progressSnapshot = await progressRef.get();
      for (var doc in progressSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      // Cancel the timer if it's set for this habit
      timers[habitName]?.cancel();
      timers.remove(habitName);
      timerMessages.remove(habitName);

      // Refresh the UI
      setState(() {});
    } catch (e) {
      print("Error deleting habit and progress: $e");
    }
  }


  Widget buildHabitTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final habitName = doc.id;

    return FutureBuilder<bool>(
      future: isHabitDone(habitName),
      builder: (context, snapshot) {
        final isDone = snapshot.data ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -10,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddHabitScreen(
                              habitName: habitName,
                              goal: data['goal'],
                              category: data['category'],
                              time: data['time'],
                              motivation: data['motivation'],
                            ),
                          ),
                        );

                      } else if (value == 'delete') {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Delete Habit"),
                            content: const Text("Are you sure you want to delete this habit?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                        if (shouldDelete == true) {
                          await deleteHabitAndProgress(habitName);
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text("Edit")),
                      PopupMenuItem(value: 'delete', child: Text("Delete")),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['habit_name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F0E47),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (data['goal'] != null) Text("🎯 Goal: ${data['goal']}"),
                    if (data['category'] != null) Text("📂 Category: ${data['category']}"),
                    if (data['time'] != null) Text("⏰ Preferred Time: ${data['time']}"),
                    if (data['motivation'] != null) Text("💡 Motivation: ${data['motivation']}"),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isDone,
                              onChanged: (val) async {
                                if (val == true) {
                                  await markHabitDone(habitName);
                                } else {
                                  await unmarkHabitDone(habitName);
                                }
                                setState(() {});
                              },
                            ),
                            Text(
                              isDone ? "Completed" : "Pending",
                              style: TextStyle(
                                color: isDone ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => startTimerDialog(habitName),
                          icon: const Icon(Icons.timer),
                          label: const Text("Start Timer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0F0E47),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (timerMessages.containsKey(habitName))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          timerMessages[habitName]!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F0E47),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddHabitScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF0F0E47),
        foregroundColor: Colors.white,
      ),
      body:  Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDDDE6), Color(0xFF6A82FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top:40.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Daily Habits",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('user_habits')
                      .doc('daily_habits')
                      .collection('habits')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "No daily habits yet",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F0E47),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Start your journey with one step at a time 🌱",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: docs.map((doc) => buildHabitTile(doc)).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
