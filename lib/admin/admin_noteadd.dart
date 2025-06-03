import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadNotesPage extends StatefulWidget {
  @override
  _UploadNotesPageState createState() => _UploadNotesPageState();
}

class _UploadNotesPageState extends State<UploadNotesPage> {
  final _formKey = GlobalKey<FormState>();
  String? department, semester, subject, unit, title, url;

  final List<String> semestersList = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
  ];

  Future<void> uploadNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      department = department?.toUpperCase(); // Convert to uppercase

      final docRef = FirebaseFirestore.instance.collection('departments').doc(department);
      final docSnapshot = await docRef.get();

      // If department doesn't exist, create it with base structure
      if (!docSnapshot.exists) {
        await docRef.set({'semesters': {}});
      }

      final docData = (await docRef.get()).data()!;
      final semesters = Map<String, dynamic>.from(docData['semesters'] ?? {});
      final currentSemester = semesters[semester] ?? {'subjects': {}};
      final subjects = Map<String, dynamic>.from(currentSemester['subjects'] ?? {});
      final units = List.from(subjects[subject]?[unit] ?? []);

      units.add({
        'title': title,
        'url': url,
        'unit': unit,
      });

      // Upload data
      await docRef.update({
        'semesters.$semester.subjects.$subject.$unit': units,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Note uploaded successfully!')));
      _formKey.currentState!.reset();
      setState(() => semester = null); // Reset dropdown
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Color(0xFFfff8e5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(70),
                ),
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 200,
                  width: 200,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildTextField('Department', (val) => department = val),
                        buildDropdownField('Semester'),
                        buildTextField('Subject', (val) => subject = val),
                        buildTextField('Unit', (val) => unit = val),
                        buildTextField('Title', (val) => title = val),
                        buildTextField('PDF URL', (val) => url = val),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: uploadNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text('Upload', style: TextStyle(color: Colors.yellow, fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, Function(String?) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Enter $label' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget buildDropdownField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: semester,
        items: semestersList.map((sem) {
          return DropdownMenuItem(
            value: sem,
            child: Text(sem, style: TextStyle(color: Colors.black)),
          );
        }).toList(),
        onChanged: (val) => setState(() => semester = val),
        onSaved: (val) => semester = val,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        validator: (val) => val == null ? 'Please select a semester' : null,
      ),
    );
  }
}
