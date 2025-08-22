import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddShortTermGoalScreen extends StatefulWidget {
  const AddShortTermGoalScreen({super.key});

  @override
  State<AddShortTermGoalScreen> createState() => _AddShortTermGoalScreenState();
}

class _AddShortTermGoalScreenState extends State<AddShortTermGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalNameController = TextEditingController();
  final _milestonesController = TextEditingController();
  final _rewardController = TextEditingController();
  final List<TextEditingController> _subtaskControllers = [];
  final List<Map<String, dynamic>> _progress = []; // Renamed here

  DateTime _startDate = DateTime.now();
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  bool _manualTracking = true;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 14)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  void _addSubtaskField() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _addProgress() { // Renamed method
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Progress Update'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Progress'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _progress.add({
                      'text': controller.text.trim(),
                      'completed': false,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            )
          ],
        );
      },
    );
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final goalName = _goalNameController.text.trim();
    final goalData = {
      'goal_name': goalName,
      'deadline': _deadline,
      'milestones': _milestonesController.text.trim(),
      'reward': _rewardController.text.trim(),
      'tracking_type': _manualTracking ? 'manual' : 'subtasks',
      'reminder': _reminderEnabled ? _reminderTime?.format(context) : null,
      'created_at': DateTime.now(),
    };

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('shortterm habits')
        .collection('habits')
        .doc(goalName);

    await docRef.set(goalData);

    if (_manualTracking) {
      await docRef.collection('progress').add({
        'logs': _progress,
        'updated_at': DateTime.now(),
      });
    } else {
      // Only add subtasks if at least one valid one exists
      final validSubtasks = _subtaskControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (validSubtasks.isNotEmpty) {
        for (var subtask in validSubtasks) {
          await docRef.collection('subtasks').add({
            'title': subtask,
            'completed': false,
          });
        }
      }
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _milestonesController.dispose();
    _rewardController.dispose();
    for (var controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Add Short-Term Goal", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDDDE6), Color(0xFF6A82FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Small goals set the pace and each step forward brings the dream within reach.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_goalNameController, 'Goal Name'),
                        ListTile(
                          tileColor: Colors.white.withOpacity(0.85),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          title: Text('Deadline: ${DateFormat.yMMMd().format(_deadline)}', style: const TextStyle(fontSize: 16)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: _pickDeadline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(_milestonesController, 'Planned Milestones (Optional)'),
                        _buildTextField(_rewardController, 'Post Completion Reward (Optional)'),
                        const SizedBox(height: 16),
                        _buildTrackingTypeSelector(),
                        if (_manualTracking)
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _addProgress, // Renamed here
                                child: const Text("Add Progress Log"),
                              ),
                              ..._progress.map((log) => ListTile(
                                leading: Icon(log['completed'] ? Icons.check_circle : Icons.radio_button_unchecked),
                                title: Text(log['text']),
                              )),
                            ],
                          )
                        else
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _addSubtaskField,
                                child: const Text("Add Subtask"),
                              ),
                              ..._subtaskControllers.asMap().entries.map((entry) {
                                int index = entry.key;
                                TextEditingController controller = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(controller, 'Subtask'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          if (index >= 0 && index < _subtaskControllers.length) {
                                            setState(() {
                                              _subtaskControllers.removeAt(index);
                                            });
                                          }
                                        },

                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          value: _reminderEnabled,
                          onChanged: (val) => setState(() => _reminderEnabled = val),
                          title: const Text('Set Reminder'),
                        ),
                        if (_reminderEnabled)
                          ListTile(
                            tileColor: Colors.white.withOpacity(0.85),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            title: Text(
                              _reminderTime != null
                                  ? 'Reminder Time: ${_reminderTime!.format(context)}'
                                  : 'Pick Reminder Time',
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: const Icon(Icons.access_time),
                            onTap: _pickReminderTime,
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveGoal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F0E47),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Save Goal", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) =>
        val != null && val.isEmpty ? '$label cannot be empty' : null,
      ),
    );
  }

  Widget _buildTrackingTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Progress Tracker Type:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: _manualTracking,
              onChanged: (val) => setState(() => _manualTracking = val!),
            ),
            const Text('Manual (Wednesday Check-ins)'),
          ],
        ),
        Row(
          children: [
            Radio<bool>(
              value: false,
              groupValue: _manualTracking,
              onChanged: (val) => setState(() => _manualTracking = val!),
            ),
            const Text('Checklist (Subtasks)'),
          ],
        ),
      ],
    );
  }
}
