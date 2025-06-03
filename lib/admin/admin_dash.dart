import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<AdminDashboard> {
  String userName = "Fetching...";

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => userName = "Not Found");
      return;
    }

    String email = user.email ?? "";
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() => userName = querySnapshot.docs.first['name'] ?? "Admin");
    } else {
      setState(() => userName = "Admin");
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFfff8e5),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(70)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/logo.png", height: 160),
                      SizedBox(height: 10),
                      Text(
                        '"Collaborate. Learn. Achieve."',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Reggae One',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Hello $userName!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Rammetto One',
                            color: Color(0xFF0a0a0a),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Buttons Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: 330,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomButton(
                          icon: Icons.event,
                          text: 'Event Updater',
                          onPressed: () => Navigator.pushNamed(context, '/eventupdate'),
                        ),
                        CustomButton(
                          icon: Icons.note_add,
                          text: 'Notes Adder',
                          onPressed: () => Navigator.pushNamed(context, '/noteadd'),
                        ),
                        CustomButton(
                          icon: Icons.feedback,
                          text: 'Feedback Provider',
                          onPressed: () => Navigator.pushNamed(context, '/feedp'),
                        ),
                        CustomButton(
                          icon: Icons.star_border,
                          text: 'Class Scheduler',
                          onPressed: () => Navigator.pushNamed(context, '/class'),
                        ),
                        CustomButton(
                          icon: Icons.chat,
                          text: 'Chatbot',
                          onPressed: () => Navigator.pushNamed(context, '/chatgpt'),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // Footer Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      CustomIconButton(
                        text: 'About Me',
                        icon: Icons.person,
                        onPressed: () => Navigator.pushNamed(context, '/about'),
                      ),
                      CustomIconButton(
                        text: 'Logout',
                        icon: Icons.logout,
                        onPressed: logout,
                      ),
                      CustomIconButton(
                        text: 'Contact',
                        icon: Icons.contact_mail,
                        onPressed: () => Navigator.pushNamed(context, '/contact'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Main dashboard button
class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  CustomButton({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.black),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFC107),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          minimumSize: Size(290, 55),
        ),
        onPressed: onPressed,
        label: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            fontFamily: 'Rammetto One',
            color: Color(0xFF0a0a0a),
          ),
        ),
      ),
    );
  }
}

// Footer icon button
class CustomIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  CustomIconButton({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 18),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: onPressed,
        label: Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
