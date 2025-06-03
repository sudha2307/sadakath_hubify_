import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResetPasswordPage extends StatelessWidget {
  final TextEditingController rollController = TextEditingController();

  void _sendResetEmail(BuildContext context) async {
    String roll = rollController.text.trim();

    if (roll.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your roll number'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('rollNumber', isEqualTo: roll)
          .get();

      if (snapshot.docs.isEmpty) throw 'No user found for this roll number';

      String email = snapshot.docs.first['email'];

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset link sent to $email'), backgroundColor: Colors.green),
      );

      Navigator.pop(context); // Go back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(400, 800),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  Center(
                    child: Image.asset(
                      'assets/images/reset.png', // <- Use your illustration here
                      height: 160.h,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Center(
                    child: Text(
                      "Forgot your password?",
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Center(
                    child: Text(
                      "Enter your Roll Number so we can send you a reset link.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    "Roll Number",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: rollController,
                    decoration: InputDecoration(
                      hintText: "e.g. 22CS123",
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _sendResetEmail(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 16.h),
                      ),
                      child: Text(
                        "Send Email",
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 20.sp, color: Colors.black54),
                          SizedBox(width: 6.w),
                          Text(
                            "Back to Login",
                            style: TextStyle(color: Colors.black54, fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
