import 'package:flutter/material.dart';
import 'package:habit_tracker/views/My%20Habits/add_longterm_goal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // To format date

class LongTermGoalScreen extends StatefulWidget {
  @override
  State<LongTermGoalScreen> createState() => _LongTermGoalScreenState();
}

class _LongTermGoalScreenState extends State<LongTermGoalScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  // Function to format date
  String formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> addProgress(String habitName, String goalTitle, String progressValue) async {
    final timestamp = Timestamp.now();
    final progressRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('longterm habits')
        .collection('habits')
        .doc(goalTitle)
        .collection('progress');

    await progressRef.add({
      'timestamp': timestamp,
      'progress': int.tryParse(progressValue) ?? 0, // storing numeric progress
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress added successfully')),
    );
  }

  Future<void> showAddProgressDialog(String goalTitle) async {
    TextEditingController progressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Progress"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter progress value (in numbers):"),
            TextField(
              controller: progressController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Progress Value'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              addProgress(goalTitle, goalTitle, progressController.text);
              Navigator.pop(ctx);
            },
            child: const Text("Add Progress"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteHabit(String goalTitle) async {
    final habitRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('longterm habits')
        .collection('habits')
        .doc(goalTitle);

    final progressRef = habitRef.collection('progress');

    // Deleting all progress entries
    final progressSnapshot = await progressRef.get();
    for (var doc in progressSnapshot.docs) {
      await doc.reference.delete();
    }

    // Deleting the habit itself
    await habitRef.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit and its progress deleted successfully')),
    );
  }

  Widget buildHabitTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final habitName = doc.id;

    // Handling null values for habit_name, goal_title, category, motivation, start_date, end_date
    final goalTitle = data['goal_title'] ?? 'No Goal Title';
    final habitNameText =data['goal_title'];
    final category = data['category'] ?? 'No Category';
    final motivation = data['motivation'] ?? 'No Motivation';
    final startDate = data['start_date'] != null ? formatDate(data['start_date']) : 'No Start Date';
    final endDate = data['end_date'] != null ? formatDate(data['end_date']) : 'No End Date';

     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habitNameText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F0E47),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("🎯 Goal: $goalTitle"),
                  const SizedBox(height: 10),
                  Text("📂 Category: $category"),
                  const SizedBox(height: 10),
                  Text("💡 Motivation: $motivation"),
                  const SizedBox(height: 10),
                  Text("📅 Start Date: $startDate"),
                  const SizedBox(height: 10),
                  Text("📅 End Date: $endDate"),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => showAddProgressDialog(goalTitle),
                    child: const Text("Add Progress"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F0E47),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteHabit(goalTitle),
              ),
            ),
          ],
        ),
      ),
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
                builder: (context) => const AddLongTermGoalScreen()),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Long Term Goals",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('user_habits')
                  .doc('longterm habits')
                  .collection('habits')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text("No long-term habits yet"));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: docs.map((doc) => buildHabitTile(doc)).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
