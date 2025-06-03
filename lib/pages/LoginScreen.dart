import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotRollController = TextEditingController();

  Future<void> loginWithRollNumber(String rollNumber, String password, BuildContext context) async {
    try {
      String lowercaseRoll = rollNumber.toLowerCase(); // Convert to lowercase

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('rollNumber', isEqualTo: lowercaseRoll)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No user found with the given roll number');
      }

      String email = snapshot.docs.first['email'];

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushNamed(
        context,
        '/dash',
        arguments: lowercaseRoll,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: forgotRollController,
                  decoration: InputDecoration(
                    hintText: 'Enter your Roll Number',
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () async {
                    String roll = forgotRollController.text.trim().toLowerCase();

                    if (roll.isEmpty) {
                      Navigator.pop(context);
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

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reset link sent to $email'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                  ),
                  child: Text("Send Reset Link", style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(400, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.yellow[700],
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20.h),
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      Center(
                        child: Image.asset(
                          "assets/images/logo.png",
                          height: 130.h,
                          width: 130.w,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      _buildTextField(rollNumberController, "Roll Number"),
                      SizedBox(height: 20.h),
                      _buildTextField(passwordController, "Password", obscureText: true),
                      SizedBox(height: 40.h),
                      ElevatedButton(
                        onPressed: () async {
                          await loginWithRollNumber(
                            rollNumberController.text.trim(),
                            passwordController.text.trim(),
                            context,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.yellow[700],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: GestureDetector(
                          onTap: () => _showForgotPasswordDialog(context),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: CustomIconButton(
                          icon: Icons.verified_user,
                          text: 'Admin Login',
                          onPressed: () => Navigator.pushNamed(context, '/admin'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  CustomIconButton({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20.sp),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
