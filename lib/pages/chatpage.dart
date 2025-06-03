import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, String>> messages = [];
  TextEditingController controller = TextEditingController();
  late AutoRefreshingAuthClient client;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeClient();
  }

  Future<void> initializeClient() async {
    try {
      // Load the JSON credentials file
      final String jsonString =
      await rootBundle.loadString('assets/hubify-td-80f4c6c9b20e.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Create authenticated client
      final credentials = ServiceAccountCredentials.fromJson(jsonData);
      client = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/cloud-platform'],
      );

      setState(() {
        isInitialized = true;
      });

      print("Client initialized successfully.");
    } catch (e) {
      print("Error initializing client: $e");
    }
  }

  Future<void> getResponse(String userMessage) async {
    if (!isInitialized) {
      print("Client is not initialized yet.");
      return;
    }

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

    final response = await client.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final botReply = responseData['queryResult']['fulfillmentText'];
      setState(() {
        messages.add({"role": "bot", "text": botReply});
      });
    } else {
      print("Error: ${response.body}");
    }
  }

  void sendMessage(String text) {
    setState(() {
      messages.add({"role": "user", "text": text});
    });
    controller.clear();
    getResponse(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TD-Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message['text']!),
                  subtitle: Text(message['role']!),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: 'Type your message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => sendMessage(controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
