import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisteredActivity extends StatefulWidget {
  @override
  _RegisteredActivityState createState() => _RegisteredActivityState();
}

class _RegisteredActivityState extends State<RegisteredActivity> {
  final TextEditingController _searchController = TextEditingController();
  String _searchString = '';
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Query registrationsQuery = FirebaseFirestore.instance
        .collection('registrations')
        .where('userId', isEqualTo: user?.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Registered Events')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Registered Events',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchString = value.toLowerCase();
                });
              },
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: registrationsQuery.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final eventIds = snapshot.data?.docs
                          .map((doc) => doc['eventId'] as String)
                          .toList() ??
                      [];

                  if (eventIds.isEmpty) {
                    return const Center(
                        child: Text('No registered events found.'));
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('events')
                        .where(FieldPath.documentId, whereIn: eventIds)
                        .snapshots(),
                    builder: (context, eventSnapshot) {
                      if (eventSnapshot.hasError) {
                        return const Text('Something went wrong');
                      }
                      if (eventSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var filteredDocs = eventSnapshot.data?.docs.where((doc) {
                            return doc['activityName']
                                .toLowerCase()
                                .contains(_searchString);
                          }).toList() ??
                          [];

                      return ListView(
                        children: filteredDocs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          DateTime startDate =
                              DateTime.parse(data['startDate']);
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
                _showRatingDialog(context, eventId, title);
              },
              child: const Text('Rate'),
            ),
          ],
        ),
      ),
    );
  }
}

void _showRatingDialog(BuildContext context, String eventId, String title) {
  final TextEditingController ratingController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Rate $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Enter your rating (1-5):'),
            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Rating"),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Submit'),
            onPressed: () {
              int? rating = int.tryParse(ratingController.text);
              if (rating != null && rating > 0 && rating <= 5) {
                _submitRating(eventId, rating, context);
                Navigator.of(context).pop();
              } else {
                Fluttertoast.showToast(
                  msg: "Please enter a valid rating between 1 and 5.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            },
          ),
        ],
      );
    },
  );
}

void _submitRating(String eventId, int rating, BuildContext context) {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentReference eventDoc =
        FirebaseFirestore.instance.collection('events').doc(eventId);

    eventDoc.set({
      'ratings': {user.uid: rating}
    }, SetOptions(merge: true)).then((value) {
      Fluttertoast.showToast(
        msg: "Rating Submitted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: "Failed to submit rating: $error",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  } else {
    Fluttertoast.showToast(
      msg: "No user signed in",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
