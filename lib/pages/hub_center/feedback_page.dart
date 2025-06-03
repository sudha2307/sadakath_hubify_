import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  Map<String, String> responses = {};
  bool isLoading = true;

  TextEditingController emailController = TextEditingController();
  String? userEnteredEmail;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('feedback_questions')
        .orderBy('timestamp')
        .get();

    setState(() {
      questions = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'question': doc['question'],
          'options': List<String>.from(doc['options']),
        };
      }).toList();
      isLoading = false;
    });
  }

  Future<void> sendFeedbackEmail() async {
    String userEmail = userEnteredEmail ?? "Unknown Email";

    String feedbackContent = responses.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': "service_41pu58c",
        'template_id': "template_ua70zwi",
        'user_id': "tAB5bQ9mSXnyrkagT",
        'template_params': {
          'user_email': userEmail,
          'feedback_content': feedbackContent,
          'to_email': 'hubify.sac@gmail.com',
        },
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Feedback sent successfully")),
      );
    } else {
      print('Failed to send email: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send feedback")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Step 1: Ask for email
    if (userEnteredEmail == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter Your Email",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "example@gmail.com",
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellowAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (emailController.text.contains('@')) {
                      setState(() {
                        userEnteredEmail = emailController.text;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter a valid email")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[800],
                  ),
                  child: Text("Continue"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Step 2: Show questions
    if (questions.isEmpty) {
      return Scaffold(
        body: Center(child: Text("No feedback questions available")),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Text("Feedback", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question['question'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20),
            Column(
              children: question['options'].map<Widget>((option) {
                return RadioListTile<String>(
                  title: Text(option, style: TextStyle(color: Colors.white)),
                  value: option,
                  groupValue: responses[question['id']],
                  onChanged: (value) {
                    setState(() {
                      responses[question['id']] = value!;
                    });
                  },
                  activeColor: Colors.yellow[800],
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex--;
                      });
                    },
                    child: Text("Previous"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (responses[question['id']] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select an option")),
                      );
                      return;
                    }

                    if (currentQuestionIndex < questions.length - 1) {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    } else {
                      sendFeedbackEmail();
                    }
                  },
                  child: Text(currentQuestionIndex == questions.length - 1 ? "Submit" : "Next"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
