import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateAccountComponent extends StatefulWidget {
  @override
  _CreateAccountComponentState createState() => _CreateAccountComponentState();
}

class _CreateAccountComponentState extends State<CreateAccountComponent> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _rollNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _message;
  Color? _messageColor;
  String? _passwordStrength;

  final _formKey = GlobalKey<FormState>();

  bool isValidRollNumber(String rollNo) {
    if (rollNo.length < 4) return false;

    final firstTwo = rollNo.substring(0, 2);
    final lastTwo = rollNo.substring(rollNo.length - 2);

    final isFirstTwoDigits = RegExp(r'^\d{2}$').hasMatch(firstTwo);
    final isLastTwoDigits = RegExp(r'^\d{2}$').hasMatch(lastTwo);

    return isFirstTwoDigits && isLastTwoDigits;
  }



  String? checkPasswordStrength(String password) {
    if (password.length < 6) return 'Weak';
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasDigits = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    if (hasLetters && hasDigits && hasSpecial) return 'Stronger';
    return 'Strong';
  }

  Future<void> _createAccount() async {

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final rollNo = _rollNoController.text.trim().toLowerCase();

    if (!isValidRollNumber(rollNo)) {
      setState(() {
        _message = "Invalid roll number format!";
        _messageColor = Colors.red;
      });
      return;
    }

    // Validate password match
    if (password != confirmPassword) {
      setState(() {
        _message = "Passwords do not match!";
        _messageColor = Colors.red;
      });
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('rollNumber', isEqualTo: rollNo)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _message = "This roll number is already registered.";
          _messageColor = Colors.red;
        });
        return;
      }

      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore.collection('users').add({
        'rollNumber': rollNo,
        'email': email,
      });

      setState(() {
        _message = "Account created successfully!";
        _messageColor = Colors.green;
      });

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushNamed(context, '/login');
      });
    } catch (e) {
      setState(() {
        _message = "Error: ${e.toString()}";
        _messageColor = Colors.red;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _rollNoController.addListener(() {
      final text = _rollNoController.text.toLowerCase();
      _rollNoController.value = _rollNoController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });

    _passwordController.addListener(() {
      final password = _passwordController.text;
      setState(() {
        _passwordStrength = checkPasswordStrength(password);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_circle_left_outlined,
                              color: Colors.black, size: 35),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      Image.asset(
                        "assets/images/logo.png",
                        height: 150,
                        width: 150,
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow[800],
                        ),
                      ),

                      SizedBox(height: 20),

                      _buildTextField("Roll Number", _rollNoController),
                      SizedBox(height: 10),

                      _buildTextField("Email", _emailController,
                          inputType: TextInputType.emailAddress),
                      SizedBox(height: 10),

                      _buildTextField("Password", _passwordController,
                          isPassword: true),
                      if (_passwordStrength != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Password Strength: $_passwordStrength",
                            style: TextStyle(
                                fontSize: 13,
                                color: _passwordStrength == "Weak"
                                    ? Colors.red
                                    : _passwordStrength == "Strong"
                                    ? Colors.orange
                                    : Colors.green),
                          ),
                        ),
                      SizedBox(height: 10),

                      _buildTextField("Confirm Password",
                          _confirmPasswordController,
                          isPassword: true),

                      SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          elevation: 5,
                        ),
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      if (_message != null)
                        Text(
                          _message!,
                          style: TextStyle(
                            fontSize: 14,
                            color: _messageColor,
                          ),
                        ),

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account?",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700])),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              " Login",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isPassword = false,
        TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.amber[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.amber[800]!),
        ),
      ),
    );
  }
}
