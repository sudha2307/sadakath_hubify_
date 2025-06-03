import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class FeedbackProviderPage extends StatefulWidget {
  @override
  _FeedbackProviderPageState createState() => _FeedbackProviderPageState();
}

class _FeedbackProviderPageState extends State<FeedbackProviderPage> {
  List<QuestionModel> questions = [QuestionModel()];

  void addNewQuestion() {
    setState(() {
      questions.add(QuestionModel());
    });
  }

  void removeQuestion(int index) {
    setState(() {
      questions.removeAt(index);
    });
  }

  Future<void> uploadQuestions() async {
    for (var question in questions) {
      if (question.questionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all question fields")),
        );
        return;
      }

      List<String> options = question.optionControllers.map((c) => c.text).toList();

      await FirebaseFirestore.instance.collection('feedback_questions').add({
        'question': question.questionController.text,
        'type': question.selectedType,
        'options': question.selectedType == 'Dropdown' || question.selectedType == 'Options' ? options : [],
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Questions Uploaded Successfully")),
    );

    setState(() {
      questions = [QuestionModel()]; // Reset after uploading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Feedback Provider', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return GlassContainer(
                    child: buildQuestionCard(index),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addNewQuestion,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
              child: Text("+ New Question", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: uploadQuestions,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: Text("Upload All", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuestionCard(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: questions[index].questionController,
          decoration: InputDecoration(hintText: "Enter question"),
        ),
        SizedBox(height: 10),
        DropdownButton<String>(
          value: questions[index].selectedType,
          onChanged: (value) {
            setState(() {
              questions[index].selectedType = value!;
            });
          },
          items: ['Dropdown', 'Options', 'TextField', 'Range']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
        ),
        if (questions[index].selectedType == 'Dropdown' || questions[index].selectedType == 'Options')
          Column(
            children: List.generate(questions[index].optionControllers.length, (i) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: questions[index].optionControllers[i],
                      decoration: InputDecoration(hintText: "Option ${i + 1}"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        questions[index].optionControllers.removeAt(i);
                      });
                    },
                  ),
                ],
              );
            }),
          ),
        if (questions[index].selectedType == 'Dropdown' || questions[index].selectedType == 'Options')
          TextButton(
            onPressed: () {
              setState(() {
                questions[index].optionControllers.add(TextEditingController());
              });
            },
            child: Text("+ Add Option"),
          ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => removeQuestion(index),
        ),
      ],
    );
  }
}

class QuestionModel {
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> optionControllers = [];
  String selectedType = 'TextField';
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}
