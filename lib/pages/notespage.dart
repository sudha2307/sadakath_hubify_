import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String? selectedDepartment;
  String? selectedSemester;
  String? selectedSubject;
  String? selectedUnit;

  List<String> departments = [];
  List<String> semesters = [];
  List<String> subjects = [];
  List<String> units = [];
  List<Map<String, dynamic>> notes = [];

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
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }


  Future<void> fetchSemesters(String department) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('departments').doc(department).get();
    final data = docSnapshot.data();
    if (data != null && data['semesters'] is Map) {
      setState(() {
        semesters = (data['semesters'] as Map).keys.cast<String>().toList();
        subjects = [];
        units = [];
        notes = [];
      });
    }
  }

  Future<void> fetchSubjects(String department, String semester) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('departments').doc(department).get();
    final data = docSnapshot.data();
    if (data != null && data['semesters'] is Map) {
      final semesterData = data['semesters'][semester];
      if (semesterData != null && semesterData['subjects'] is Map) {
        setState(() {
          subjects = (semesterData['subjects'] as Map).keys.cast<String>().toList();
          units = [];
          notes = [];
        });
      }
    }
  }

  Future<void> fetchUnits(String department, String semester, String subject) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('departments').doc(department).get();
    final data = docSnapshot.data();
    if (data != null && data['semesters'] is Map) {
      final semesterData = data['semesters'][semester];
      if (semesterData != null && semesterData['subjects'] is Map) {
        final subjectData = semesterData['subjects'][subject];
        if (subjectData != null && subjectData is Map) {
          setState(() {
            units = subjectData.keys.cast<String>().toList();
            notes = [];
          });
        }
      }
    }
  }

  Future<void> fetchNotes(String department, String semester, String subject, String unit) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('departments').doc(department).get();
    final data = docSnapshot.data();
    if (data != null && data['semesters'] is Map) {
      final semesterData = data['semesters'][semester];
      if (semesterData != null && semesterData['subjects'] is Map) {
        final subjectData = semesterData['subjects'][subject];
        if (subjectData != null && subjectData is Map) {
          final unitData = subjectData[unit];
          if (unitData != null && unitData is List) {
            setState(() {
              notes = unitData.map((note) => Map<String, dynamic>.from(note)).toList();
            });
          }
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF5E6),
      body: Column(
        children: [
          // 📌 Glassmorphic Styled Header
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(70)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset("assets/images/logo.png", height: 200, width: 200),
              ],
            ),
          ),

          // 📌 Title "Notes"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.yellow[800],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  "Notes",
                  style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(width: 10,height: 20,),

          // 📌 Dropdowns in Two Rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    buildDropdown('Department', departments, selectedDepartment, (value) {
                      setState(() {
                        selectedDepartment = value;
                        selectedSemester = null;
                        selectedSubject = null;
                        selectedUnit = null;
                        fetchSemesters(value!);
                      });
                    }),
                    SizedBox(width: 10,height: 20,),
                    buildDropdown('Semester', semesters, selectedSemester, (value) {
                      setState(() {
                        selectedSemester = value;
                        selectedSubject = null;
                        selectedUnit = null;
                        fetchSubjects(selectedDepartment!, value!);
                      });
                    }),
                  ],
                ),
                SizedBox(width: 10,height: 25,),
                Row(
                  children: [
                    buildDropdown('Subject', subjects, selectedSubject, (value) {
                      setState(() {
                        selectedSubject = value;
                        selectedUnit = null;
                        fetchUnits(selectedDepartment!, selectedSemester!, value!);
                      });
                    }),
                    SizedBox(width: 10,height: 20,),
                    buildDropdown('Unit', units, selectedUnit, (value) {
                      setState(() {
                        selectedUnit = value;
                        fetchNotes(selectedDepartment!, selectedSemester!, selectedSubject!, value!);
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),

          // 📌 Notes Display with Scroll Behavior
          SizedBox(height: 20),
          Expanded(
            child: notes.isEmpty
                ? Center(child: Text('Get Your Notes Here!!', style: TextStyle(color: Colors.grey)))
                : Scrollbar(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Card(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(note['title'] ?? 'No Title', style: TextStyle(color: Colors.white)),
                      subtitle: Text(note['unit'] ?? 'No Unit', style: TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                        icon: Icon(Icons.link, color: Colors.yellow),
                        onPressed: () => _launchURL(note['url'] ?? ''),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📌 Custom Dropdown Widget
  Widget buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(label, style: TextStyle(color: Colors.yellow, fontStyle: FontStyle.italic))),
            dropdownColor: Colors.black,
            isExpanded: true,
            items: items.map((item) => DropdownMenuItem(value: item, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(item, style: TextStyle(color: Colors.white))))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
