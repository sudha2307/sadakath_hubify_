import 'package:flutter/material.dart';

class AboutPageComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E5),
      body: Column(
        children: [
          // Top Section (Non-scrollable)
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60.0),
                bottomRight: Radius.circular(60.0),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Image.asset(
                  "assets/images/logo.png",
                  height: 200,
                  width: 200,
                ),
                SizedBox(height: 10),

              ],
            ),
          ),
          SizedBox(height: 10.0),
          // About Me Button
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.yellow[800],
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text(
              'About Me',
              style: TextStyle(
                fontFamily: 'Rammetto One',
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Us',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'This Mobile application is developed by third-year IT students in collaboration with the Student Council of Sadakathullah Appa College. Designed to empower students, this platform serves as an all-in-one companion for academic and campus life.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.0,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Key Features:',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(height: 10),
                    featureItem('Quick Notes: Simplify exam preparation by creating and managing notes.'),
                    featureItem('Important Dates & Day Orders: Stay updated with academic schedules and day orders effortlessly.'),
                    featureItem('AI Chatbot: Chat with our intelligent assistant for instant help and information.'),
                    featureItem('Trending Events: Explore the latest happenings and events on campus.'),
                    SizedBox(height: 20),
                    Text(
                      'Main Uses of the Application',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    featureItem('Enhanced Exam Preparation: Students can quickly create, store, and organize notes for better focus and efficiency during exam time.'),
                    featureItem('Academic Schedule Management: Access day orders and important academic dates, ensuring no deadline or schedule is missed.'),
                    featureItem('Personalized Assistance: The AI-powered chatbot offers instant help, answering queries and providing guidance for academic and personal needs.'),
                    featureItem('Stay Connected with Campus Events: Explore trending events and activities happening in college, keeping students informed and engaged.'),
                    featureItem('Streamlined Student Experience: By centralizing essential features, this app helps students save time, stay organized, and focus on their goals.'),
                    Text(
                      'This application is tailored to make college life smoother, smarter, and more productive for every student.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.0,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget featureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8.0, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
