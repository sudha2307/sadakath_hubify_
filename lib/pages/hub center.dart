import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HubCenter extends StatefulWidget {
  @override
  _HubCenterState createState() => _HubCenterState();
}

class _HubCenterState extends State<HubCenter> {
  String rollNumber = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserRollNumber();

  }



  Future<void> fetchUserRollNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => rollNumber = "Not Found");
      return;
    }

    String email = user.email ?? "";
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() => rollNumber = querySnapshot.docs.first['rollNumber']);
    } else {
      setState(() => rollNumber = "Not Found");
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: Color(0xFFfff8e5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Top Section
                    Container(
                      width: double.infinity,
                      height: size.height * 0.38,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(70),
                        ),
                      ),
                      padding: EdgeInsets.only(top: size.height * 0.06),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            "assets/images/logo.png",
                            height: size.height * 0.18,
                            width: size.height * 0.18,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '"Collaborate. Learn. Achieve."',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Reggae One',
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 13),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
                            height: 40,
                            width: 260,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC107),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                'Hello $rollNumber!',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontFamily: 'Rammetto One',
                                  color: Color(0xFF0a0a0a),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 58),

                    // Buttons Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: width * 0.79,
                        height: 300,

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
                        child: Wrap(
                          spacing: 17,
                          runSpacing: 17,
                          alignment: WrapAlignment.center,
                          children: [
                            CustomMiniButton(
                              text: 'Attendance',
                              icon: Icons.check_circle,
                              onPressed: () => Navigator.pushNamed(context, '/attendance'),
                            ),
                            CustomMiniButton(
                              text: 'Results',
                              icon: Icons.assessment,
                              onPressed: () => Navigator.pushNamed(context, '/result'),
                            ),
                            CustomMiniButton(
                              text: 'Feed Backs',
                              icon: Icons.feedback,
                              onPressed: () => Navigator.pushNamed(context, '/feed'),
                            ),
                            CustomMiniButton(
                              text: 'Chatbot',
                              icon: Icons.chat,
                              onPressed: () => Navigator.pushNamed(context, '/chatgpt'),
                            ),
                            CustomMiniButton(
                              text: 'Your Files',
                              icon: Icons.add_circle_outline,
                              onPressed: () => Navigator.pushNamed(context, '/file'),
                            ),
                            CustomMiniButton(
                              text: 'CGPA Calculator',
                              icon: Icons.calculate_rounded,
                              onPressed: () => Navigator.pushNamed(context, '/cgpa'),
                            ),
                            CustomMiniButton(
                              text: 'My Notes',
                              icon: Icons.note_alt,
                              onPressed: () => Navigator.pushNamed(context, '/mynotes'),
                            ),
                            CustomMiniButton(
                              text: 'Important Links',
                              icon: Icons.link_rounded,
                              onPressed: () => Navigator.pushNamed(context, '/links'),
                            ),
                          ],
                        ),


                      ),
                    ),

                    SizedBox(height: 70),

                    footerButtons(context),

                    SizedBox(height: 20), // Extra space at bottom


                  ],
                ),
              ),
            ),
          );
        },

      ),
    );

  }

}
Widget footerButtons(BuildContext context) {
  Future<void> launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'hubify.sac@gmail.com',
      query: Uri.encodeFull('subject=Contact from App&body=Hi Team,'),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open the email app")),
      );
    }
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CustomIconButton(
        text: 'About Me',
        icon: Icons.person,

        onPressed: () => Navigator.pushNamed(context, '/about'),
      ),
      const SizedBox(width: 18),
      LogoutButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
      ),
      const SizedBox(width: 18),
      CustomIconButton(
        text: 'Contact',
        icon: Icons.contact_mail,
        onPressed: () => Navigator.pushNamed(context, '/contact'),
      ),

    ],
  );
}


// Custom Mini Button (Yellow)
class CustomMiniButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  CustomMiniButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * 0.31, // two per row with spacing
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
          color: Color(0xFF0a0a0a),
        ),
        label: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Rammetto One',
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF0a0a0a),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFC107),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }
}


// Footer Buttons (Black Rounded)
class CustomIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  CustomIconButton({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: Size(115, 35),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: const CircleAvatar(
        backgroundColor: Colors.red,
        radius: 28,
        child: Icon(Icons.logout, color: Colors.white, size: 26),
      ),
    );
  }
}
