import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyNotesPage extends StatefulWidget {
  @override
  _MyNotesPageState createState() => _MyNotesPageState();
}

class _MyNotesPageState extends State<MyNotesPage> {
  final user = FirebaseAuth.instance.currentUser!;
  late CollectionReference notesRef;

  @override
  void initState() {
    super.initState();
    notesRef = FirebaseFirestore.instance.collection('notes').doc(user.uid).collection('userNotes');
    _initializeDefaultNotes();
  }

  Future<void> _initializeDefaultNotes() async {
    final snapshot = await notesRef.get();
    if (snapshot.size == 0) {
      await notesRef.doc('Marks').set({
        'title': 'Marks',
        'content': 'Enter your marks here...',
        'date': _formattedNow(),
        'editable': true,
        'deletable': false,
      });
      await notesRef.doc('Leave days').set({
        'title': 'Leave days',
        'content': 'Track your leave days here...',
        'date': _formattedNow(),
        'editable': true,
        'deletable': false,
      });
    }
  }

  String _formattedNow() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year} ${TimeOfDay.fromDateTime(now).format(context)}";
  }

  void _showEditPopup(DocumentSnapshot note) {
    final TextEditingController controller = TextEditingController(text: note['content']);
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Edit Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 10),
                TextField(
                  controller: controller,
                  maxLines: null,
                  decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Edit your note'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context)),
                    ElevatedButton(
                      child: Text('Save'),
                      onPressed: () async {
                        await notesRef.doc(note.id).update({
                          'content': controller.text,
                          'date': _formattedNow(),
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _addNewNote() {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("New Note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: contentController, decoration: InputDecoration(labelText: "Content")),
          ],
        ),
        actions: [
          TextButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            child: Text("Add"),
            onPressed: () async {
              await notesRef.doc(titleController.text).set({
                'title': titleController.text,
                'content': contentController.text,
                'date': _formattedNow(),
                'editable': true,
                'deletable': true,
              });
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Widget _noteTile(DocumentSnapshot note) {
    final bgColor = {
      'Marks': Colors.lightBlue[100],
      'Leave days': Colors.purple[100],
    }[note['title']] ?? Colors.primaries[note.id.hashCode % Colors.primaries.length][100];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _showEditPopup(note),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 5),
                Text(note['date'], style: TextStyle(fontSize: 12)),
              ],
            )),
            if (note['deletable'])
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => notesRef.doc(note.id).delete(),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Notes")),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map(_noteTile).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewNote,
        child: Icon(Icons.add),
      ),
    );
  }
}
