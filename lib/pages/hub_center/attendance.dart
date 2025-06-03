import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendancePage> {
  final TextEditingController _regNoController = TextEditingController();
  List<dynamic> _attendanceRecords = [];
  bool _dataFetched = false;
  int totalPresent = 0, totalAbsent = 0, totalOD = 0;
  String selectedYear = "3rd Year";
  String studentName = "", adminNo = "";
  String errorMessage = "";

  final String thirdYearApi = "https://sac-academic-gateway-1.onrender.com/attendance";
  final String firstYearApi = "https://attendance-hubify-1.onrender.com/attendance_1st_year";

  Future<void> fetchAttendance() async {
    final url = Uri.parse(selectedYear == "3rd Year" ? thirdYearApi : firstYearApi);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"reg_no": _regNoController.text}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        _attendanceRecords = data[selectedYear == "3rd Year" ? "Records" : "Attendance"] ?? [];
        studentName = data["Name"] ?? "N/A";
        adminNo = data["AdminNo"] ?? "N/A";

        if (_attendanceRecords.isNotEmpty) {
          totalPresent = int.tryParse(_attendanceRecords[0]['Present'].toString()) ?? 0;
          totalAbsent = int.tryParse(_attendanceRecords[0]['Absent'].toString()) ?? 0;
          totalOD = int.tryParse(_attendanceRecords[0]['OD'].toString()) ?? 0;
          _dataFetched = true;
        }
      });
    } else {
      setState(() {
        errorMessage = "Failed to fetch attendance. Please try again.";
      });
    }
  }

  // Function for 1st Year Data Table
  Widget buildFirstYearDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 10,
        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.green),
        columns: [
          DataColumn(label: Text('RegNo', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('SubCode', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Total', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Present', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Absent', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('OD', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Total_Present', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Percentage', style: TextStyle(color: Colors.white))),
        ],
        rows: _attendanceRecords.map((record) {
          return DataRow(cells: [
            DataCell(Text(record['RegNo'] ?? 'N/A')),
            DataCell(Text(record['SubCode'] ?? 'N/A')),
            DataCell(Text(record['Total']?.toString() ?? '0')),
            DataCell(Text(record['Present']?.toString() ?? '0')),
            DataCell(Text(record['Absent']?.toString() ?? '0')),
            DataCell(Text(record['OD']?.toString() ?? '0')),
            DataCell(Text(record['Total_Present']?.toString() ?? '0')),
            DataCell(Text(record['Present_Percentage']?.toString() ?? '0')),
          ]);
        }).toList(),
      ),
    );
  }

  // Function for 3rd Year Data Table
  Widget buildThirdYearDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 10,
        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.green),
        columns: [
          DataColumn(label: Text('Course Code', style: TextStyle(color: Colors.white))),

          DataColumn(label: Text('Total', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Present', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Absent', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('OD', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Percentage', style: TextStyle(color: Colors.white))),
        ],
        rows: _attendanceRecords.map((record) {
          return DataRow(cells: [
            DataCell(Text(record['CCode'] ?? 'N/A')),

            DataCell(Text(record['Total'] ?? 'N/A')),
            DataCell(Text(record['Present'] ?? 'N/A')),
            DataCell(Text(record['Absent'] ?? 'N/A')),
            DataCell(Text(record['OD'] ?? 'N/A')),
            DataCell(Text(record['Percentage'] ?? 'N/A')),
          ]);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfff8e5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(70)),
              ),
              child: Center(child: Image.asset("assets/images/logo.png", height: 200, width: 200)),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Attendance Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    width: 160,
                    decoration: BoxDecoration(color: Colors.yellow[800], borderRadius: BorderRadius.circular(30)),
                    child: Center(
                      child: Text("Attendance", style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Input Fields
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _regNoController,
                          decoration: InputDecoration(
                            hintText: 'Enter Your Roll Number',
                            filled: true,
                            fillColor: Colors.yellow[800],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedYear,
                        items: ["3rd Year", "1st Year"].map((String year) {
                          return DropdownMenuItem<String>(value: year, child: Text(year));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedYear = value!);
                        },
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: fetchAttendance,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: Text("View", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Display Student Info
                  if (_dataFetched) ...[
                    Text("Name: $studentName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Admin No: $adminNo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    SizedBox(height: 20),
                  ],

                  // Attendance Summary (only for 3rd Year)
                  if (_dataFetched && selectedYear == "3rd Year") ...[
                    Text("Attendance Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  ],

                  // Data Table for First Year
                  if (_dataFetched && selectedYear == "1st Year") ...[
                    buildFirstYearDataTable(),
                  ],

                  // Data Table for Third Year
                  if (_dataFetched && selectedYear == "3rd Year") ...[
                    buildThirdYearDataTable(),
                  ],

                  SizedBox(height: 20),

                  // Pie Charts for Each Subject (for both 1st Year and 3rd Year)
                  if (_dataFetched) ...[
                    if (selectedYear == "3rd Year") ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _attendanceRecords.map((record) => Column(
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                child: PieChart(
                                  PieChartData(sections: [
                                    PieChartSectionData(
                                      value: double.tryParse(record['Present'].toString()) ?? 0.0,
                                      title: "Present",
                                      color: Colors.green,
                                    ),
                                    PieChartSectionData(
                                      value: double.tryParse(record['Absent'].toString()) ?? 0.0,
                                      title: "Absent",
                                      color: Colors.red,
                                    ),
                                    PieChartSectionData(
                                      value: double.tryParse(record['OD'].toString()) ?? 0.0,
                                      title: "OD",
                                      color: Colors.orange,
                                    ),
                                  ]),
                                ),
                              ),
                              SizedBox(height: 10),
                              // Subject Code Box with Drop Shadow
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  record['SName'] ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          )).toList(),
                        ),
                      ),
                    ],
                    if (selectedYear == "1st Year") ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _attendanceRecords.map((record) => Column(
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                child: PieChart(
                                  PieChartData(sections: [
                                    PieChartSectionData(
                                      value: double.tryParse(record['Present'].toString()) ?? 0.0,
                                      title: "Present",
                                      color: Colors.green,
                                    ),
                                    PieChartSectionData(
                                      value: double.tryParse(record['Absent'].toString()) ?? 0.0,
                                      title: "Absent",
                                      color: Colors.red,
                                    ),
                                    PieChartSectionData(
                                      value: double.tryParse(record['OD'].toString()) ?? 0.0,
                                      title: "OD",
                                      color: Colors.orange,
                                    ),
                                  ]),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  record['SubCode'] ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          )).toList(),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget AttendanceBox(String label, int count, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(
            "$label\n$count",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
