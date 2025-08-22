import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddNotePage extends StatefulWidget {
  final DocumentSnapshot? existingNote;

  AddNotePage({this.existingNote});

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  int characterCount = 0;

  bool get isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _titleController.text = widget.existingNote!['title'];
      _contentController.text = widget.existingNote!['content'];
    }

    _titleController.addListener(_updateCharacterCount);
    _contentController.addListener(_updateCharacterCount);
    _updateCharacterCount();
  }

  void _updateCharacterCount() {
    setState(() {
      characterCount =
          _titleController.text.length + _contentController.text.length;
    });
  }

  Future<void> _saveNote() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('personal_blogging');

    if (isEditing) {
      await collection.doc(widget.existingNote!.id).update({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'updatedAt': Timestamp.now(),
      });
    } else {
      await collection.add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    }

    Navigator.pop(context); // Go back after saving
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateCharacterCount);
    _contentController.removeListener(_updateCharacterCount);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        "${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        actions: [
          IconButton(
              icon: Icon(Icons.save_alt, color: Colors.black),
              onPressed: _saveNote),
          IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration.collapsed(hintText: "Title"),
            ),
            SizedBox(height: 8),
            Text(
              "$formattedDate   $characterCount characters",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration.collapsed(hintText: "Start typing"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
