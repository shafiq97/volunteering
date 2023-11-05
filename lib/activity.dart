import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchString = '';

  @override
  Widget build(BuildContext context) {
    // Create a reference to the events collection
    CollectionReference events =
        FirebaseFirestore.instance.collection('events');

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Page')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Events',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchString = value.toLowerCase();
                });
              },
            ),
            Expanded(
              child: StreamBuilder(
                stream: events.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    return doc['activityName']
                        .toLowerCase()
                        .contains(_searchString);
                  }).toList();
                  return ListView(
                    children: filteredDocs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      DateTime startDate = DateTime.parse(data['startDate']);
                      return EventTile(
                        eventId: document.id,
                        title: data['activityName'],
                        description: data['description'],
                        date: DateFormat('dd MMM yyyy').format(startDate),
                        imageUrl: data['posterUrl'],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
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
  final String? imageUrl; // imageUrl can be null

  EventTile({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl, // imageUrl is now optional
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Check if imageUrl is null before trying to load it
            if (imageUrl != null) // Only display image if the URL is not null
              Image.network(
                imageUrl!,
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
                _showRegistrationDialog(context, eventId, title);
              },
              child: const Text('Register here'),
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
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Register for $title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Enter your name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: "Enter your email"),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Register'),
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
  registrations.add({
    'eventId': eventId,
    'name': name,
    'email': email,
    'registeredAt': FieldValue.serverTimestamp(),
  }).then((value) {
    Fluttertoast.showToast(
      msg: "User Registered",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }).catchError((error) {
    Fluttertoast.showToast(
      msg: "Failed to register user: $error",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  });
}
