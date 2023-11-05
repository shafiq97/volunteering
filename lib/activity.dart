import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create a reference to the events collection
    CollectionReference events =
        FirebaseFirestore.instance.collection('events');

    return Scaffold(
      appBar: AppBar(title: Text('Activity Page')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        // Use a StreamBuilder to listen to live updates from Firestore
        child: StreamBuilder(
          stream: events.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            // Map the documents to widgets
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                DateTime startDate = DateTime.parse(data['startDate']);

                return EventTile(
                  eventId: document.id,
                  title: data['activityName'],
                  description: data['description'],
                  date: DateFormat('dd MMM yyyy')
                      .format(startDate), // Format the date as you need
                  imageUrl: data[
                      'posterUrl'], // Assuming 'posterUrl' is stored in the document
                );
              }).toList(),
            );
          },
        ),
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
      margin: EdgeInsets.symmetric(vertical: 8.0),
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
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(description),
            SizedBox(height: 10),
            Text('Date: $date'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showRegistrationDialog(
                    context, eventId, title); // Pass the event ID and title
              },
              child: Text('Register here'),
            ),
          ],
        ),
      ),
    );
  }
}

void _showRegistrationDialog(
    BuildContext context, String eventId, String title) {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false, // User must tap button to close the dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Register for $title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: "Enter your name"),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(hintText: "Enter your email"),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Register'),
            onPressed: () {
              _registerForEvent(
                  eventId, nameController.text, emailController.text, context);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _registerForEvent(
    String eventId, String name, String email, BuildContext context) {
  CollectionReference registrations =
      FirebaseFirestore.instance.collection('registrations');

  // Add the registration
  registrations.add({
    'eventId': eventId,
    'name': name,
    'email': email,
    'registeredAt': FieldValue.serverTimestamp(), // Sets the server timestamp
  }).then((value) {
    Fluttertoast.showToast(
        msg: "User Registered",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }).catchError((error) {
    Fluttertoast.showToast(
        msg: "Failed to register user: $error",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  });
}
