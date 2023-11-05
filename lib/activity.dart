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
      appBar: AppBar(title: Text('Activity Page')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
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
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
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
                _showRegistrationDialog(context, eventId, title);
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
    barrierDismissible: false,
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
