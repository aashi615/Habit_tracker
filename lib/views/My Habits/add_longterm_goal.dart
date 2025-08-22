import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddLongTermGoalScreen extends StatefulWidget {
  const AddLongTermGoalScreen({super.key});

  @override
  State<AddLongTermGoalScreen> createState() => _AddLongTermGoalScreenState();
}

class _AddLongTermGoalScreenState extends State<AddLongTermGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _goalTitleController = TextEditingController();
  final _motivationController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String _selectedPriority = 'Medium';
  String _selectedCategory = 'Personal';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isCustomCategory = false;

  final List<String> _priorities = ['High', 'Medium', 'Low'];
  final List<String> _categories = ['Health', 'Study', 'Work', 'Personal'];

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final goalTitle = _goalTitleController.text.trim();
    final goalData = {
      'goal_title': goalTitle,
      'priority': _selectedPriority,
      'category': _isCustomCategory && _customCategoryController.text.trim().isNotEmpty
          ? _customCategoryController.text.trim()
          : _selectedCategory,
      'motivation': _motivationController.text.trim().isEmpty
          ? null
          : _motivationController.text.trim(),
      'start_date': _selectedStartDate != null ? Timestamp.fromDate(_selectedStartDate!) : null,
      'end_date': _selectedEndDate != null ? Timestamp.fromDate(_selectedEndDate!) : null,
      'created_at': FieldValue.serverTimestamp(),
    };

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('user_habits')
        .doc('longterm habits')
        .collection('habits')
        .doc(goalTitle);

    await docRef.set(goalData);



    try {
      await docRef.set(goalData, SetOptions(merge: true)); // Use merge for updating
      Navigator.pop(context);
    } catch (e) {
      print("Error saving goal: $e");
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
          "Add Long Term Goal",
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
                        _buildTextField(_goalTitleController, 'Goal Title'),
                        _buildCategorySelector(),
                        ListTile(
                          tileColor: Colors.white.withOpacity(0.85),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          title: Text(
                            _selectedStartDate != null
                                ? 'Start Date: ${_selectedStartDate!.toLocal()}'
                                : 'Pick Start Date',
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _pickDate(context, true),
                        ),
                        ListTile(
                          tileColor: Colors.white.withOpacity(0.85),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          title: Text(
                            _selectedEndDate != null
                                ? 'End Date: ${_selectedEndDate!.toLocal()}'
                                : 'Pick End Date',
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _pickDate(context, false),
                        ),
                        _buildTextField(_motivationController, 'Motivation (Optional)', isNumber: false),
                        const SizedBox(height: 12),
                        _buildChipsSelector(),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveGoal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F0E47),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Save Goal",
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

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
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
              : _buildDropdown('Category', _categories, _selectedCategory, (val) => setState(() => _selectedCategory = val!)),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selected, ValueChanged<String?> onChanged) {
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
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        validator: (val) => val == null || val.trim().isEmpty ? 'Select $label' : null,
      ),
    );
  }

  Widget _buildChipsSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8.0,
        children: _priorities
            .map((priority) => ChoiceChip(
          label: Text(priority),
          selected: _selectedPriority == priority,
          onSelected: (selected) {
            setState(() {
              _selectedPriority = priority;
            });
          },
        ))
            .toList(),
      ),
    );
  }
}
