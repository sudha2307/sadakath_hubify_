import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _logoVisible = false;

  @override
  void initState() {
    super.initState();
    _fadeInLogo(); // Start fade-in animation
    _checkUserLogin();
  }
  void _fadeInLogo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _logoVisible = true;
    });
  }

  Future<void> _checkUserLogin() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String email = currentUser.email!;
        var snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          String rollNumber = snapshot.docs.first['rollNumber'];
          Navigator.pushReplacementNamed(context, '/dash', arguments: rollNumber);
          return;
        } else {
          await FirebaseAuth.instance.signOut(); // Invalid user, force logout
        }
      }
    } catch (e) {
      print("Auto-login error: $e");
    }

    setState(() {
      _isLoading = false; // Stay on start screen
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Loading screen with fade-in logo animation
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _logoVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1000),
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 150,
                  width: 150,
                ),
              ),
              const SizedBox(height: 30),
              CircularProgressIndicator(color: Colors.yellow[700]),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              Image.asset(
                "assets/images/logo.png",
                height: 200,
                width: 200,
              ),
              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createac');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                ),
                child: Text(
                  'Create Account',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              Spacer(),

              Column(
                children: [
                  Text(
                    "from",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    "TECH DOCTORS",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 75),
            ],
          ),
        ),
      ),
    );
  }
}
