import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FirstYearAttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<FirstYearAttendanceScreen> {
  final TextEditingController _regNoController = TextEditingController();
  List<dynamic> _attendanceRecords = [];
  bool _dataFetched = false;
  int totalPresent = 0, totalAbsent = 0, totalOD = 0;
  String errorMessage = "";

  Future<void> fetchAttendance() async {
    final url = Uri.parse("https://sac-academic-gateway-1.onrender.com/attendance");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"reg_no": _regNoController.text}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        _attendanceRecords = data["Records"] ?? [];
        if (_attendanceRecords.isNotEmpty) {
          totalPresent = double.parse(_attendanceRecords[0]['Present']).toInt();
          totalAbsent = double.parse(_attendanceRecords[0]['Absent']).toInt();
          totalOD = double.parse(_attendanceRecords[0]['OD']).toInt();
          _dataFetched = true;
        }
      });
    } else {
      setState(() {
        errorMessage = "Failed to fetch attendance. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfff8e5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(70),
                ),
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 200,
                  width: 200,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.yellow[800],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          "Attendance",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _regNoController,
                          decoration: InputDecoration(
                            hintText: 'Enter Your Roll Number',
                            filled: true,
                            fillColor: Colors.yellow[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: fetchAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "View",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  if (_dataFetched) ...[
                    Text(
                      "Attendance Summary",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AttendanceBox("Present", totalPresent, Colors.green),
                        AttendanceBox("Absent", totalAbsent, Colors.red),
                        AttendanceBox("OD", totalOD, Colors.orange),
                      ],
                    ),
                    SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 10,
                        headingRowColor:
                        MaterialStateColor.resolveWith((states) => Colors.green),
                        columns: [
                          DataColumn(label: Text('Course Code', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Subject', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Total', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Present', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Absent', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('OD', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Percentage', style: TextStyle(color: Colors.white))),
                        ],
                        rows: _attendanceRecords.map((record) {
                          return DataRow(cells: [
                            DataCell(Text(record['CCode'] ?? 'N/A')),
                            DataCell(Text(record['SName'] ?? 'N/A')),
                            DataCell(Text(record['Total'] ?? 'N/A')),
                            DataCell(Text(record['Present'] ?? 'N/A')),
                            DataCell(Text(record['Absent'] ?? 'N/A')),
                            DataCell(Text(record['OD'] ?? 'N/A')),
                            DataCell(Text(record['Percentage'] ?? 'N/A')),
                          ]);
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 30,),
                    // Pie Chart
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                                value: totalPresent.toDouble(), title: "Present", color: Colors.green),
                            PieChartSectionData(
                                value: totalAbsent.toDouble(), title: "Absent", color: Colors.red),
                            PieChartSectionData(value: totalOD.toDouble(), title: "OD", color: Colors.orange),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget AttendanceBox(String label, int count, Color color) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(count.toString(), style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    ),
  );
}
