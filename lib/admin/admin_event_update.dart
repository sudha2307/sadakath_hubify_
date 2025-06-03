import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

class EventUpdaterPage extends StatefulWidget {
  @override
  _EventUpdaterPageState createState() => _EventUpdaterPageState();
}

class _EventUpdaterPageState extends State<EventUpdaterPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageLinkController = TextEditingController();

  DateTime? _selectedTime;
  File? _imageFile;
  Uint8List? _webImage;
  bool _isUploading = false;
  bool _showSuccessMessage = false;
  bool _showErrorMessage = false;
  bool _isUsingImageLink = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
          _isUsingImageLink = false;
          _imageLinkController.clear();
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _webImage = null;
          _isUsingImageLink = false;
          _imageLinkController.clear();
        });
      }
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedTime = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute,
          );
        });
      }
    }
  }
  void _showDeleteEventsPopup() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            height: 400,
            width: double.maxFinite,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Uploaded Events",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('events')
                        .orderBy('timeStamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text("No events found."));
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'Untitled';
                          final time = (data['timeStamp'] as Timestamp).toDate();
                          return ListTile(
                            title: Text(title),
                            subtitle:
                            Text(DateFormat('yyyy-MM-dd – HH:mm').format(time)),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEvent(doc.id),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteEvent(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: ${e.toString()}")),
      );
    }
  }


  Future<void> _uploadEvent() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _bodyController.text.isEmpty ||
        _selectedTime == null) {
      setState(() => _showErrorMessage = true);
      return;
    }

    setState(() {
      _isUploading = true;
      _showErrorMessage = false;
    });

    try {
      String imageUrl = _imageLinkController.text;

      if (_imageFile != null || _webImage != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child('events/$fileName.jpg');
        UploadTask uploadTask = kIsWeb
            ? storageRef.putData(_webImage!)
            : storageRef.putFile(_imageFile!);
        TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // 🛑 Use default image if imageLink is still empty
      if (imageUrl.isEmpty) {
        imageUrl = 'https://sadakath.ac.in/images/department/english/banner/banner_2.jpg';
      }

      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'body': _bodyController.text,
        'imageUrl': imageUrl,
        'timeStamp': Timestamp.fromDate(_selectedTime!),
      });

      setState(() {
        _showSuccessMessage = true;
        _resetForm();
      });

      Future.delayed(Duration(seconds: 2), () {
        setState(() => _showSuccessMessage = false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _bodyController.clear();
    _imageLinkController.clear();
    _selectedTime = null;
    _imageFile = null;
    _webImage = null;
    _isUsingImageLink = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF5E6), // Light cream background
      body: SafeArea(
        child: Column(
          children: [
            // 📌 Your Glassmorphic Styled Header
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
                  SizedBox(height: 10),
                  Image.asset("assets/images/logo.png", height: 200, width: 200),
                ],
              ),
            ),

            // 📌 Main Form Section (Wrapped in Expanded + Scroll)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Upload Event",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                            SizedBox(height: 15),
                            _buildTextField("Title", _titleController),
                            _buildTextField("Description", _descriptionController, maxLines: 3),
                            _buildTextField("Content", _bodyController, maxLines: 5),

                            TextButton.icon(
                              icon: Icon(Icons.calendar_month),
                              label: Text("Pick Date & Time"),
                              onPressed: _pickDateTime,
                            ),
                            if (_selectedTime != null)
                              Text("Selected: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedTime!)}"),

                            SizedBox(height: 10),
                            if (!_isUsingImageLink)
                              TextButton.icon(
                                icon: Icon(Icons.image),
                                label: Text("Pick Image"),
                                onPressed: _pickImage,
                              ),
                            if (_imageFile != null || _webImage != null)
                              Text("Image selected ✔", style: TextStyle(color: Colors.green)),

                            if (_imageFile == null && _webImage == null)
                              _buildTextField("Or paste Image URL", _imageLinkController, onChanged: (val) {
                                setState(() => _isUsingImageLink = val.isNotEmpty);
                              }),

                            SizedBox(height: 15),
                            if (_showErrorMessage)
                              _buildMessage("All fields are required!", Colors.red),
                            if (_showSuccessMessage)
                              _buildMessage("Event uploaded successfully!", Colors.green),

                            SizedBox(height: 20),
                            _isUploading
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton.icon(
                              onPressed: _uploadEvent,
                              icon: Icon(Icons.upload),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              label: Text("Upload Event"),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: _showDeleteEventsPopup,
                              icon: Icon(Icons.delete),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              label: Text("Delete Uploaded Events"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildMessage(String msg, Color color) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Center(child: Text(msg, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
    );
  }
}


