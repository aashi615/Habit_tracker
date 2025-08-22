import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/views/My%20Habits/add_short_term_Habits.dart';

class WeeklyHabitsScreen extends StatefulWidget {
  const WeeklyHabitsScreen({super.key});

  @override
  State<WeeklyHabitsScreen> createState() => _WeeklyHabitsScreenState();
}

class _WeeklyHabitsScreenState extends State<WeeklyHabitsScreen> {
  final todayStr =
      "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> submitManualProgress(String goalName, double value) async {

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('shortterm habits')
        .collection('habits')
        .doc(goalName)
        .collection('progress')
        .doc(todayStr)
        .set({
      'value': value,
      'timestamp': Timestamp.now(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Progress submitted successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> markSubtaskDone(String goalName, String subtaskId) async {
    final habitRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('shortterm habits')
        .collection('habits')
        .doc(goalName);

    final subtaskRef = habitRef.collection('subtasks').doc(subtaskId);

    // Mark subtask as done
    await subtaskRef.update({'isDone': true});

    // Recalculate progress
    final subtasksSnapshot = await habitRef.collection('subtasks').get();
    final total = subtasksSnapshot.docs.length;
    final completed = subtasksSnapshot.docs
        .where((doc) => doc.data()['isDone'] == true)
        .length;

    final progress = (completed / total) * 100;

    await habitRef
        .collection('progress')
        .doc(todayStr)
        .set({'value': progress, 'timestamp': Timestamp.now()},
        SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Subtask marked as done!"), backgroundColor: Colors.green),
    );
  }


  Future<void> deleteHabit(String goalName) async {
    try {
      final goalRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('user_habits')
          .doc('shortterm habits')
          .collection('habits')
          .doc(goalName);

      final progressSnapshot = await goalRef.collection('progress').get();
      for (var doc in progressSnapshot.docs) {
        await doc.reference.delete();
      }

      final subtasksSnapshot = await goalRef.collection('subtasks').get();
      for (var doc in subtasksSnapshot.docs) {
        await doc.reference.delete();
      }

      await goalRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Habit and all associated data deleted successfully!"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error occurred while deleting the habit."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showManualInputDialog(String goalName) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Progress"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter progress value"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                await submitManualProgress(goalName, value);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget buildGoalTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final goalName = doc.id;
    final trackingType = data['tracking_type'];
    final milestonesList = (data['milestones'] as String?)?.split(',') ?? [];

    final deadlineDate = (data['deadline'] is Timestamp)
        ? (data['deadline'] as Timestamp).toDate()
        : null;

    final progressLogsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('shortterm habits')
        .collection('habits')
        .doc(goalName)
        .collection('progress')
        .orderBy('timestamp', descending: true)
        .limit(1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['goal_name'] ?? goalName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F0E47),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteHabit(goalName),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (data['milestones'] != null)
              Text("📍 Milestones: ${milestonesList.join(', ')}"),
            if (deadlineDate != null)
              Text("⏳ Deadline: ${DateFormat('dd MMM yyyy').format(deadlineDate)}"),
            if (data['reward'] != null)
              Text("🎁 Reward: ${data['reward']}"),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: progressLogsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final progressDocs = snapshot.data?.docs ?? [];

                if (progressDocs.isEmpty) {
                  return const Text("No progress logged yet.");
                }

                final progressData =
                progressDocs.first.data() as Map<String, dynamic>;
                final progressValue = progressData['value'] ?? 0.0;
                final timestamp =
                (progressData['timestamp'] as Timestamp).toDate();

                return ListTile(
                  title: Text("Progress: ${progressValue.toStringAsFixed(2)}%"),
                  subtitle: Text(
                      "Last Updated: ${DateFormat('dd MMM yyyy, hh:mm a').format(timestamp)}"),
                );
              },
            ),
            const SizedBox(height: 16),
            if (trackingType == 'manual')
              ElevatedButton.icon(
                onPressed: () => showManualInputDialog(goalName),
                icon: const Icon(Icons.add),
                label: const Text("Add Progress"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F0E47),
                  foregroundColor: Colors.white,
                ),
              ),
            if (trackingType == 'subtasks')
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('user_habits')
                    .doc('shortterm habits')
                    .collection('habits')
                    .doc(goalName)
                    .collection('subtasks')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final subtaskDocs = snapshot.data?.docs ?? [];

                  if (subtaskDocs.isEmpty) {
                    return const Text("No subtasks found.");
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("📋 Subtasks:"),
                      ...subtaskDocs.map((subtaskDoc) {
                        final subtaskData = subtaskDoc.data() as Map<String, dynamic>;
                        final subtaskTitle = subtaskData['title'] ?? subtaskDoc.id;
                        final isDone = subtaskData['isDone'] ?? false;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("🔸 $subtaskTitle"),
                          trailing: ElevatedButton(
                            onPressed: isDone
                                ? null
                                : () => markSubtaskDone(goalName, subtaskDoc.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDone ? Colors.green : Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isDone ? "Completed" : "Mark Done"),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final goalsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('shortterm habits')
        .collection('habits');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddShortTermGoalScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF0F0E47),
        foregroundColor: Colors.white,
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
        child: Column(
          children: [
            const SizedBox(height: 55),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Short Term Goals",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),

                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: goalsRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No short-term goals available."),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  return ListView(
                    children: docs.map(buildGoalTile).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}