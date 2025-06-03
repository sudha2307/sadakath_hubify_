import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final TextEditingController _regNoController = TextEditingController();
  String? _exam = "Nov 2024"; // Default exam option
  List<dynamic> _results = [];
  bool _dataFetched = false;

  Future<void> fetchResults() async {
    final url = Uri.parse("https://results-0ojd.onrender.com/get_result");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "reg_no": _regNoController.text,
          "exam": _exam,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _results = jsonResponse['results'] ?? [];
          _dataFetched = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load results: ${response.statusCode}')),
        );
      }
    } catch (error) {
      setState(() {
        _results = [];
        _dataFetched = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching results: $error')),
      );
    }
  }


  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              ['Subject Code', 'Subject Name', 'I', 'E', 'T', 'P/RA'],
              ..._results.map((result) {
                return [
                  result['sub_code']?.toString() ?? 'N/A',
                  result['sub_name']?.toString() ?? 'N/A',
                  result['int_mark']?.toString() ?? 'N/A',
                  result['ext_mark']?.toString() ?? 'N/A',
                  result['total']?.toString() ?? 'N/A',
                  result['result']?.toString() ?? 'N/A',
                ];
              }).toList(),
            ],
          );
        },
      ),
    );

    if (await Permission.storage.request().isGranted) {
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = await getExternalStorageDirectory();
      } else {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      final directory = Directory('${downloadsDirectory!.path}/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final filePath = "${directory.path}/result.pdf";
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Saved at $filePath')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  bool _validateInput() {
    if (_regNoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your roll number')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfff8e5),
      body: Column(
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.yellow[800],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Result",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextField(
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_validateInput()) {
                          fetchResults();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
                    SizedBox(height: 29),
                    _dataFetched
                        ? _results.isNotEmpty
                        ? Column(
                      children: [
                        Text(
                          _regNoController.text,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: DataTable(
                              columnSpacing: 15,
                              columns: [
                                DataColumn(
                                    label: Text(
                                      'Sub code',
                                      style: TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w900),
                                    )),
                                DataColumn(
                                    label: Text(
                                      'Subject Name',
                                      style: TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w900),
                                    )),
                                DataColumn(
                                    label: Text(
                                      'I',
                                      style: TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w900),
                                    )),
                                DataColumn(
                                    label: Text(
                                      'E',
                                      style: TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w900),
                                    )),
                                DataColumn(
                                    label: Text(
                                      'T',
                                      style: TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w900),
                                    )),
                                DataColumn(
                                    label: Text(
                                      'P/RA',
                                      style: TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w900),
                                    )),
                              ],
                              rows: _results.map((result) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(result['sub_code'] ?? 'N/A',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900))),
                                    DataCell(Text(result['sub_name'] ?? 'N/A',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900))),
                                    DataCell(Text(result['int_mark'] ?? 'N/A',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900))),
                                    DataCell(Text(result['ext_mark'] ?? 'N/A',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900))),
                                    DataCell(Text(result['total'] ?? 'N/A',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900))),
                                    DataCell(Text(result['result'] ?? 'N/A',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                      ],
                    )
                        : Text(
                      'No results found.',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
