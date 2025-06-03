import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CGPACalculatorPage extends StatefulWidget {
  @override
  _CGPACalculatorPageState createState() => _CGPACalculatorPageState();
}

class _CGPACalculatorPageState extends State<CGPACalculatorPage> {
  List<Course> courses = [Course()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔷 Top UI
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.deepPurple],
                ),
              ),
              child: const Text(
                "CGPA Calculator",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // 🔷 Course Table
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Expanded(child: Text("Course Name", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Text("Mark", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Text("Credits", style: TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(width: 24),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...courses.asMap().entries.map((entry) {
                          int index = entry.key;
                          Course course = entry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                // Subject
                                Expanded(
                                  child: TextFormField(
                                    controller: course.subjectController,
                                    decoration: const InputDecoration(
                                      hintText: 'Eg. Advanced Calculus',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Marks (numbers only)
                                Expanded(
                                  child: TextFormField(
                                    controller: course.markController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: const InputDecoration(
                                      hintText: 'Eg. 90',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Credits
                                Expanded(
                                  child: course.isPractical
                                      ? DropdownButtonFormField<String>(
                                    value: course.creditDropdownValue,
                                    items: ['1', '2']
                                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        course.creditDropdownValue = val!;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  )
                                      : TextFormField(
                                    controller: course.creditController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: const InputDecoration(
                                      hintText: 'Eg. 4',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Remove Button
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      courses.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),

                        // Add Course & Clear All
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  courses.add(Course());
                                });
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              icon: const Icon(Icons.add),
                              label: const Text("Add Course"),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  courses.clear();
                                  courses.add(Course());
                                });
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              icon: const Icon(Icons.clear),
                              label: const Text("Clear All"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Calculate Button
                        ElevatedButton(
                          onPressed: calculateCGPA,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade900,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text(
                            "Calculate",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void calculateCGPA() {
    double totalPoints = 0;
    double totalCredits = 0;

    for (var course in courses) {
      int? mark = int.tryParse(course.markController.text);
      int credits = course.isPractical
          ? int.parse(course.creditDropdownValue)
          : int.tryParse(course.creditController.text) ?? 0;

      if (mark == null || mark < 0 || mark > 100) {
        showError("Invalid mark found.");
        return;
      }

      double gradePoint;
      if (mark >= 90)
        gradePoint = 10;
      else if (mark >= 80)
        gradePoint = 9;
      else if (mark >= 70)
        gradePoint = 8;
      else if (mark >= 60)
        gradePoint = 7;
      else if (mark >= 50)
        gradePoint = 6;
      else if (mark >= 40)
        gradePoint = 5;
      else
        gradePoint = 0;

      totalPoints += gradePoint * credits;
      totalCredits += credits;
    }

    double cgpa = totalCredits > 0 ? totalPoints / totalCredits : 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Result"),
        content: Text("Your CGPA is: ${cgpa.toStringAsFixed(2)}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }
}

class Course {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController markController = TextEditingController();
  final TextEditingController creditController = TextEditingController();

  bool isPractical = false;
  String creditDropdownValue = '1';

  Course({this.isPractical = false});
}
