import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../notespage.dart';

class NotesAdderPage extends StatefulWidget {
  const NotesAdderPage({Key? key}) : super(key: key);

  @override
  _NotesAdderPageState createState() => _NotesAdderPageState();
}

class _NotesAdderPageState extends State<NotesAdderPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedDepartment;
  String? selectedSemester;
  String? selectedSubject;
  String title = '';
  String content = '';
  List<String> departments = [];
  List<String> semesters = [];
  List<String> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    final snapshot = await FirebaseFirestore.instance.collection('departments').get();
    setState(() {
      departments = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> addNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance
          .collection('departments')
          .doc(selectedDepartment)
          .collection('semesters')
          .doc(selectedSemester)
          .collection('subjects')
          .doc(selectedSubject)
          .collection('notes')
          .add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8e5),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Reuse UI components from NotesPage
                
                _buildTextField('Title', (value) => title = value),
                _buildTextField('Content', (value) => content = value),
                ElevatedButton(
                  onPressed: addNote,
                  child: const Text('Add Note'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onSave) {
    return TextFormField(
      onSaved: (value) => onSave(value ?? ''),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(labelText: label),
    );
  }
}
