import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FilesPage extends StatefulWidget {
  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final int maxFiles = 10;

  String get userId => _auth.currentUser?.uid ?? "guest";

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileSize = file.lengthSync();

      if (fileSize > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File too large! Max 10MB allowed.")),
        );
        return;
      }

      final existingFiles = await _firestore
          .collection('files')
          .where('userId', isEqualTo: userId)
          .get();

      if (existingFiles.docs.length >= maxFiles) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You can only upload up to $maxFiles files.")),
        );
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage.ref().child('users/$userId/$timestamp-$fileName');

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadURL = await snapshot.ref.getDownloadURL();

      await _firestore.collection('files').add({
        'userId': userId,
        'name': fileName,
        'url': downloadURL,
        'size': (fileSize / (1024 * 1024)).toStringAsFixed(2), // MB
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ File uploaded successfully")),
      );
    } catch (e) {
      print("Upload failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Upload failed. Please try again.")),
      );
    }
  }

  Future<void> _openFile(String url) async {
    try {
      await OpenFile.open(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to open file.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF5E6),
      body: Column(
        children: [
          // 🔲 Glassmorphic Styled Header
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(70)),
            ),
            child: Center(
              child: Image.asset("assets/images/logo.png", height: 200),
            ),
          ),

          // 📁 File List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('files')
                  .where('userId', isEqualTo: userId)
                  .orderBy('uploadedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (snapshot.hasError)
                  return Center(child: Text("Click  the + Button to upload  files"));

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return Center(child: Text("No files uploaded yet"));

                return ListView(
                  padding: EdgeInsets.all(16),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(data['name']),
                        subtitle: Text("${data['size']} MB"),
                        trailing: Icon(Icons.open_in_new, color: Colors.blue),
                        onTap: () => _openFile(data['url']),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),

      // ➕ Floating Upload Button
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadFile,
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
