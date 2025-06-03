import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  final Color bgColor = const Color(0xFFFFF8E5);
  final Color accentColor = Colors.yellowAccent;
  final String email = "hubify.sac@gmail.com";

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Email copied to clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Top Banner
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60.0),
                bottomRight: Radius.circular(60.0),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Image.asset(
                  "assets/images/logo.png",
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 30),

// Contact Us Button (Styled like "About Me")
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontFamily: 'Rammetto One',
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

              ],
            ),
          ),

          const SizedBox(height: 30),

          // Mail ID Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.yellow[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      email,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(context, email),
                    icon: const Icon(Icons.copy, color: Colors.white),
                    tooltip: "Copy email",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Have questions or feedback?\nWe’d love to hear from you!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[900],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Some Decorative Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              '📨 Our support team is available 24/7 to assist you.\n\n'
                  'For project collaborations, queries, or app-related issues, '
                  'feel free to drop an email. We’re here to help!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // Footer
          const Text(
            'Powered by HUBIFY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
