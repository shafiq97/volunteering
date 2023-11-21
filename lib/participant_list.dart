import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ParticipantList extends StatefulWidget {
  final String eventId;

  ParticipantList({required this.eventId});

  @override
  _ParticipantListState createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {
  @override
  Widget build(BuildContext context) {
    Query participantsQuery = FirebaseFirestore.instance
        .collection('registrations')
        .where('eventId', isEqualTo: widget.eventId);

    return Scaffold(
      appBar: AppBar(title: const Text('Participants List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: participantsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              DateTime registeredAt =
                  (data['registeredAt'] as Timestamp).toDate();
              return ListTile(
                title: Text(data['name']),
                subtitle: Text(data['email']),
                trailing: Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(registeredAt)),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class EventTile extends StatelessWidget {
  final String eventId;
  final String title;
  final String description;
  final String date;
  final String imageUrl;

  EventTile({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(description),
            const SizedBox(height: 10),
            Text('Date: $date'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParticipantList(eventId: eventId),
                  ),
                );
              },
              child: const Text('View Participants'),
            ),
          ],
        ),
      ),
    );
  }
}
