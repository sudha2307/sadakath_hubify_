import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8e5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔼 Top Header with Logo
            Container(
              width: double.infinity,
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(70)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Image.asset(
                    "assets/images/logo.png",
                    height: 180,
                    width: 180,
                  ),
                ],
              ),
            ),

            // 🔼 Title Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.yellow[800],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Events",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),

            // 📌 Events Section
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('timeStamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    "No events available",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                }

                var eventDocs = snapshot.data!.docs;

                return Container(
                  width: 300,
                  height: 320,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.yellow[800],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: eventDocs.map((event) {
                        var eventData = event.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: EventCard(
                            eventName: eventData['title'],
                            imageUrl: eventData['imageUrl'],
                            description: eventData['description'],
                            time: eventData['timeStamp'] as Timestamp?,
                            body: eventData['body'],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),
            const Text(
              ' " Tap the event to know more details " ',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}


// Event Card
class EventCard extends StatelessWidget {
  final String eventName;
  final String imageUrl;
  final String description;
  final String body;
  final Timestamp? time;

  const EventCard({
    Key? key,
    required this.eventName,
    required this.imageUrl,
    required this.description,
    required this.body,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedTime = time != null
        ? DateFormat('hh:mm a, dd MMM yyyy').format(time!.toDate())
        : "Time Not Available";

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => EventDetailPopup(
          eventName: eventName,
          imageUrl: imageUrl,
          description: description,
          body: body,
          time: formattedTime,
        ),
      ),
      child: Container(
        width: 190,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                width: 190,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
            // Adding a dark overlay
            Container(
              width: 190,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            // Positioning the event name at the bottom left corner
            Positioned(
              bottom: 20,
              left: 10,
              child: Text(
                eventName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            // Displaying the formatted time just below the event name
            Positioned(
              bottom: 5,
              left: 10,
              child: Text(
                formattedTime,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Event Detail Modal
class EventDetailPopup extends StatelessWidget {
  final String eventName;
  final String imageUrl;
  final String description;
  final String body;
  final String time;

  const EventDetailPopup({
    Key? key,
    required this.eventName,
    required this.imageUrl,
    required this.description,
    required this.body,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 40),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 300, // 4:6 ratio
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Text("Description:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(description),
                Text("Time:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(time),
                SizedBox(height: 10),
                Text("About the Event:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: SingleChildScrollView(child: Text(body)),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.close, size: 30, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
