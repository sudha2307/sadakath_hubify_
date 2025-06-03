import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UsefulLinksPage extends StatelessWidget {
  final List<Map<String, String>> links = [
    {"title": "Our College Official Website", "url": "https://sadakath.ac.in"},
    {"title": "Fees payment portal ", "url": "https://easycollege.in/sadakathullaappa/school/stuindex.aspx"},
    {"title": "Our College instagram page ", "url": "https://www.instagram.com/sadakathullahappacollege/?hl=en"},
    {"title": "Our College Youtube channel", "url": "http://youtube.com/c/sadakathullahappacollegetirunelveli "},
    {"title": "Learning Resources", "url": "https://nptel.ac.in/"},

  ];

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8e5),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: const BoxDecoration(
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
                        width: 190,
                        decoration: BoxDecoration(
                          color: Colors.yellow[800],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "Important Links",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...links.map((link) => GestureDetector(
                      onTap: () => _launchURL(link["url"]!),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link, color: Colors.black),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                link["title"]!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Rammetto One',
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
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
