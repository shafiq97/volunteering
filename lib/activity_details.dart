import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String date;

  EventDetailPage({
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                // Add your registration logic here
              },
              child: Text('Register'),
            ),
            SizedBox(height: 20), // Add some spacing
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Date: $date'),
            SizedBox(height: 10),
            Text(description),
          ],
        ),
      ),
    );
  }
}
