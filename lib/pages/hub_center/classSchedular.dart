import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClassSchedulerPage extends StatefulWidget {
  @override
  _ClassSchedulerPageState createState() => _ClassSchedulerPageState();
}

class _ClassSchedulerPageState extends State<ClassSchedulerPage> {
  String _searchQuery = "";
  List<DocumentSnapshot> _allSchedules = [];
  List<DocumentSnapshot> _filteredSchedules = [];

  @override
  void initState() {
    super.initState();
    fetchClassSchedules();
  }

  Future<void> fetchClassSchedules() async {
    final snapshot = await FirebaseFirestore.instance.collection('class_scheduler').get();
    setState(() {
      _allSchedules = snapshot.docs;
      _filteredSchedules = _allSchedules;
    });
  }

  void filterSchedules(String query) {
    final filtered = _allSchedules.where((doc) {
      final dept = doc['department'].toString().toLowerCase();
      return dept.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredSchedules = filtered;
    });
  }

  void showImagePopup(String imageUrl, String department) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Dialog(
          insetPadding: EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 40),
                padding: EdgeInsets.only(top: 60, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(imageUrl),
                    SizedBox(height: 12),
                    Text(
                      department,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.black, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Color(0xFFFDF5E6),
      body: Column(
        children: [
          // 🔲 Header
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: 220,
              decoration: BoxDecoration(
                color: Colors.yellow[800],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  "Class Scheduler",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: filterSchedules,
                    decoration: InputDecoration(
                      hintText: "Enter Your Dept Name...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {}, // Optional, for future "manual search"
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    shadowColor: Colors.grey,
                    elevation: 5,
                  ),
                  child: Text("Search"),
                ),
              ],
            ),
          ),

          // 📋 Class Schedule Results
          Expanded(
            child: _filteredSchedules.isEmpty
                ? Center(child: Text("No results found"))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredSchedules.length,
              itemBuilder: (context, index) {
                final doc = _filteredSchedules[index];
                final dept = doc['department'];
                final imageUrl = doc['imageUrl'];

                return GestureDetector(
                  onTap: () => showImagePopup(imageUrl, dept),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 8),
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        dept,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
