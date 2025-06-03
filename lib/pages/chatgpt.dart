import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Import the speech_to_text package

class ChatGemini extends StatefulWidget {
  @override
  _ChatGeminiState createState() => _ChatGeminiState();
}

class _ChatGeminiState extends State<ChatGemini> {
  List<Map<String, String>> messages = [];
  TextEditingController controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText(); // Initialize SpeechToText
  bool isListening = false; // Track mic status

  final String apiKey = "AIzaSyBjN9YVflYX-OC59-TKrHN11emm-p5AJEk"; // Replace with your actual API key

  /// Fetch response from Google Gemini AI
  Future<void> getResponse(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": userMessage});
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

      final content = [Content.text(userMessage)];
      final res = await model.generateContent(content);

      String botReply = res.text ?? "I couldn't process your request.";

      setState(() {
        messages.add({"role": "bot", "text": botReply});
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": "An error occurred. Please try again later."});
      });
    }
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    controller.clear();
    getResponse(text);
  }

  /// Start speech recognition
  void startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech Status: $status");
        if (status == "notListening") {
          setState(() {
            isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        print("Speech Error: $errorNotification");
        setState(() {
          isListening = false;
        });
      },
    );

    if (available) {
      setState(() => isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords; // Update text field with speech
          });
        },
      );
    }
  }

  /// Stop speech recognition
  void stopListening() {
    _speech.stop();
    setState(() => isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text("Chatbot", style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(15),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: isUser ? Radius.circular(20) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 14,
                                child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Bot",
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        if (!isUser) SizedBox(height: 5),
                        Text(
                          message['text']!,
                          style: TextStyle(color: isUser ? Colors.white : Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Chat Input
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                    ),
                    child: Row(
                      children: [
                        // Speech-to-text button
                        IconButton(
                          icon: Icon(
                            isListening ? Icons.mic_off : Icons.mic,
                            color: isListening ? Colors.red : Colors.blue,
                          ),
                          onPressed: isListening ? stopListening : startListening,
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: "Type or speak...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: () => sendMessage(controller.text),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
