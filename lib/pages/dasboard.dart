import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String rollNumber = "Loading...";
  List<Map<String, String>> messages = [];
  TextEditingController controller = TextEditingController();
  late AutoRefreshingAuthClient client;
  bool isInitialized = false;
  bool showChatWindow = false;

  @override
  void initState() {
    super.initState();
    fetchUserRollNumber();
    initializeClient();
  }

  Future<void> fetchUserRollNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => rollNumber = "Not Found");
      return;
    }

    String email = user.email ?? "";
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() => rollNumber = querySnapshot.docs.first['rollNumber']);
    } else {
      setState(() => rollNumber = "Not Found");
    }
  }


  Future<void> launchEmail(BuildContext context) async {
    const platform = MethodChannel('com.hubify.app/email');

    try {
      final bool result = await platform.invokeMethod('launchGmail');
      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gmail app not found!")),
        );
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error launching Gmail: ${e.message}")),
      );
    }
  }

  Future<void> initializeClient() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/hubify-td-cbfe89a383c2.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final credentials = ServiceAccountCredentials.fromJson(jsonData);
      client = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/dialogflow'],
      );
      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      print("Error initializing client: $e");
    }
  }

  Future<void> getResponse(String userMessage) async {
    if (!isInitialized) return;

    final String projectId = "hubify-td";
    final String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final Uri url = Uri.parse(
      "https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/$sessionId:detectIntent",
    );

    final Map<String, dynamic> requestBody = {
      "queryInput": {
        "text": {"text": userMessage, "languageCode": "en"}
      }
    };

    try {
      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('queryResult')) {
          final botReply = responseData['queryResult']['fulfillmentText'] ?? "No response from Dialogflow";
          setState(() {
            messages.add({"role": "bot", "text": botReply});
          });
        }
      }
    } catch (e) {
      print("Error fetching response: $e");
    }
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add({"role": "user", "text": text});
    });
    controller.clear();
    getResponse(text);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFfff8e5),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.minHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          header(height),
                          const SizedBox(height: 50),
                          buttonPanel(width),
                          const SizedBox(height: 45),
                          footerButtons(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (showChatWindow) chatPopup(width, height),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.yellow,
              child: Icon(showChatWindow ? Icons.close : Icons.chat, color: Colors.black),
              onPressed: () => setState(() => showChatWindow = !showChatWindow),
            ),
          ),
        ],
      ),
    );
  }

  Widget header(double height) {
    return Container(
      width: double.infinity,
      height: height * 0.39,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(70),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.08),
          Image.asset("assets/images/logo.png", height: height * 0.15),
          const SizedBox(height: 13),
          const Text(
            '"Collaborate. Learn. Achieve."',
            style: TextStyle(fontSize: 16, fontFamily: 'Reggae One', color: Colors.white),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
            height: 40,
            width: 260,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                'Hello $rollNumber!',
                style: const TextStyle(
                  fontSize: 19,
                  fontFamily: 'Rammetto One',
                  color: Color(0xFF0a0a0a),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonPanel(double width) {
    return Container(
      width: width * 0.74,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomButton(icon: Icons.calendar_today, text: 'Academic Calendar', onPressed: () => Navigator.pushNamed(context, '/aca')),
          CustomButton(icon: Icons.event, text: 'Events', onPressed: () => Navigator.pushNamed(context, '/event')),
          CustomButton(icon: Icons.book, text: 'Notes', onPressed: () => Navigator.pushNamed(context, '/notes')),
          CustomButton(icon: Icons.hub, text: 'Hub Center', onPressed: () => Navigator.pushNamed(context, '/hub')),
          CustomButton(icon: Icons.schedule, text: 'Class scheduler', onPressed: () => Navigator.pushNamed(context, '/class')),
        ],
      ),
    );
  }

  Widget footerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconButton(text: 'About Me', icon: Icons.person, onPressed: () => Navigator.pushNamed(context, '/about')),
        const SizedBox(width: 20),
        LogoutButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
        const SizedBox(width: 20),
        CustomIconButton(
          text: 'Contact',
          icon: Icons.contact_mail,
            onPressed: () => Navigator.pushNamed(context, '/contact')),

      ],
    );
  }

  Widget chatPopup(double width, double height) {
    return Positioned(
      bottom: 90,
      right: 20,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: width * 0.85,
          height: height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("TD Assistant", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isUser = message['role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.yellow[700] : Colors.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          message['text']!,
                          style: TextStyle(color: isUser ? Colors.black : Colors.yellow),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          filled: true,
                          fillColor: Colors.yellow[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.black),
                      onPressed: () => sendMessage(controller.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomButton({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.black),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontFamily: 'Rammetto One', color: Color(0xFF0a0a0a)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC107),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          minimumSize: const Size(double.infinity, 55),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomIconButton({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: const CircleAvatar(
        backgroundColor: Colors.red,
        radius: 28,
        child: Icon(Icons.logout, color: Colors.white, size: 26),
      ),
    );
  }
}
