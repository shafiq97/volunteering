import 'package:firebase_auth/firebase_auth.dart';
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
                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = filteredDocs[index];
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      DateTime startDate = DateTime.parse(data['startDate']);
                      double averageRating =
                          _calculateAverageRating(data['ratings']);
                      return EventTile(
                        eventId: document.id,
                        title: data['activityName'],
                        description: data['description'],
                        date: DateFormat('dd MMM yyyy').format(startDate),
                        imageUrl: data['posterUrl'],
                        rating: averageRating,
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

  double _calculateAverageRating(Map<String, dynamic>? ratings) {
    if (ratings == null || ratings.isEmpty) {
      return 0.0;
    }
    double totalRating = 0.0;
    ratings.forEach((key, value) {
      totalRating += value;
    });
    return totalRating / ratings.length;
  }
}

class EventTile extends StatelessWidget {
  final String eventId;
  final String title;
  final String description;
  final String date;
  final String? imageUrl;
  final double rating;

  EventTile({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    required this.rating,
  });

  List<Widget> buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber));
    }
    if (rating - fullStars >= 0.5) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber));
    }
    for (int i = fullStars + (rating - fullStars >= 0.5 ? 1 : 0); i < 5; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber));
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (imageUrl != null)
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: buildStars(rating),
            ),
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
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String userId = user.uid;

    CollectionReference registrations =
        FirebaseFirestore.instance.collection('registrations');

    registrations.add({
      'eventId': eventId,
      'name': name,
      'email': email,
      'registeredAt': FieldValue.serverTimestamp(),
      'userId': userId,
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
