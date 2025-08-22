import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHabitScreen extends StatefulWidget {
  final String? habitName;
  final String? goal;
  final String? category;
  final String? time;
  final String? motivation;

  const AddHabitScreen({
    super.key,
    this.habitName,
    this.goal,
    this.category,
    this.time,
    this.motivation,
  });

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  final _habitNameController = TextEditingController();
  final _goalController = TextEditingController();
  final _motivationController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String _selectedPriority = 'Medium';
  String _selectedCategory = 'Personal';
  TimeOfDay? _selectedTime;
  bool _isCustomCategory = false;

  final List<String> _priorities = ['High', 'Medium', 'Low'];
  final List<String> _categories = ['Health', 'Study', 'Work', 'Personal'];

  @override
  void initState() {
    super.initState();

    // Prefill values if habitName is provided
    if (widget.habitName != null) {
      _habitNameController.text = widget.habitName ?? '';
      _goalController.text = widget.goal ?? '';
      _motivationController.text = widget.motivation ?? '';
      _selectedCategory = widget.category ?? 'Personal';

      // Check if time is formatted correctly
      if (widget.time != null && widget.time!.contains(':')) {
        try {
          final timeParts = widget.time!.split(':');
          final hour = int.parse(timeParts[0].trim());
          final minute = int.parse(timeParts[1].split(' ')[0].trim());
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
        } catch (e) {
          print("Error parsing time: $e");
          _selectedTime = null;
        }
      } else {
        _selectedTime = null;
      }

      _isCustomCategory = widget.category == 'Custom';
      if (_isCustomCategory) {
        _customCategoryController.text = widget.category ?? '';
      }
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final habitName = _habitNameController.text.trim();

    // Generate the reference using habitName as the document ID
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('daily_habits')
        .collection('habits')
        .doc(habitName); // Habit name as document ID

    final habitData = {
      'habit_name': habitName,
      'priority': _selectedPriority,
      'goal': _goalController.text.trim(),
      'time': _selectedTime?.format(context),
      'category': _isCustomCategory && _customCategoryController.text.trim().isNotEmpty
          ? _customCategoryController.text.trim()
          : _selectedCategory,
      'motivation': _motivationController.text.trim().isEmpty
          ? null
          : _motivationController.text.trim(),
      'created_at': widget.habitName == null ? Timestamp.now() : FieldValue.serverTimestamp(),
    };

    try {
      await docRef.set(habitData, SetOptions(merge: true)); // Use merge for updating
      Navigator.pop(context);
    } catch (e) {
      print("Error saving habit: $e");
    }
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
        title: const Text(
          "Add Daily Habit",
          style: TextStyle(color: Colors.black),
        ),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Form Card
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
                        _buildTextField(_habitNameController, 'Habit Name'),
                        _buildDropdown('Priority', _priorities, _selectedPriority,
                                (val) => setState(() => _selectedPriority = val!)),
                        _buildCategorySelector(),
                        _buildTextField(_goalController, 'Goal'),
                        ListTile(
                          tileColor: Colors.white.withOpacity(0.85),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          title: Text(
                            _selectedTime != null
                                ? 'Time: ${_selectedTime!.format(context)}'
                                : 'Pick Time',
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(Icons.access_time),
                          onTap: _pickTime,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(_motivationController,
                            'Why do you want to do this? (Optional)'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveHabit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F0E47),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Save ",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (val) => val == null || val.trim().isEmpty
            ? (label.contains('(Optional)') ? null : 'Enter $label')
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selected,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selected,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: (val) =>
        val == null || val.trim().isEmpty ? 'Select $label' : null,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _isCustomCategory,
                onChanged: (value) {
                  setState(() => _isCustomCategory = value ?? false);
                },
              ),
              const Text(
                'Add custom category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          _isCustomCategory
              ? _buildTextField(_customCategoryController, 'Your Category')
              : _buildDropdown('Category', _categories, _selectedCategory,
                  (val) => setState(() => _selectedCategory = val!)),
        ],
      ),
    );
  }
}
