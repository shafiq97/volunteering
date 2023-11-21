import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:volunteering/participant_list.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchString = '';
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  void _fetchUserRole() async {
    String role = await _getUserRole();
    setState(() {
      userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    Query eventsQuery;

    if (userRole == 'organizer') {
      User? user = FirebaseAuth.instance.currentUser;
      eventsQuery = FirebaseFirestore.instance
          .collection('events')
          .where('organizerId', isEqualTo: user?.uid);
    } else {
      eventsQuery = FirebaseFirestore.instance
          .collection('events')
          .where('approved', isEqualTo: true);
    }

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
                stream: eventsQuery.snapshots(),
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
                      String urgency = data['urgency'] ??
                          'Not specified'; // Get the urgency, default to 'Not specified'

                      return EventTile(
                        eventId: document.id,
                        title: data['activityName'],
                        description: data['description'],
                        date: DateFormat('dd MMM yyyy').format(startDate),
                        imageUrl: data['posterUrl'],
                        rating: averageRating,
                        urgency: urgency,
                        organizerEmail: data['organizerEmail'],
                        onViewParticipants: () {
                          // This is the navigation callback
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ParticipantList(eventId: document.id),
                            ),
                          );
                        },
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
  final String urgency;
  final String organizerEmail;
  final VoidCallback onViewParticipants;

  EventTile({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    required this.rating,
    required this.urgency,
    required this.organizerEmail,
    required this.onViewParticipants, // Add this parameter
  });
  Future<int> _getNumberOfRegistrations(String eventId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .get();
    return querySnapshot.docs.length;
  }

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
            Text('Urgency: $urgency'), // Display urgency
            const SizedBox(height: 5),
            Text(description),
            const SizedBox(height: 10),
            Text('Date: $date'),
            const SizedBox(height: 10),
            FutureBuilder<int>(
              future: _getNumberOfRegistrations(eventId),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Text('Registrations: ${snapshot.data}');
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: buildStars(rating),
            ),
            const SizedBox(height: 10),
            FutureBuilder<String>(
              future: _getUserRole(), // You need to implement this method
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text('Error fetching user role');
                }
                String userRole = snapshot.data ?? '';

                // Show appropriate button based on user role
                if (userRole == 'organizer') {
                  return ElevatedButton(
                    onPressed: onViewParticipants, // Use the callback here
                    child: const Text('View Registered Participants'),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      _showRegistrationDialog(context, eventId, title);
                    },
                    child: const Text('Register Here'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> _getUserRole() async {
  // Logic to fetch user role from Firestore or another source
  // Example: Fetch user document from Firestore and return the 'role' field
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return userDoc.data()?['role'] ?? '';
  }
  return '';
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
    String eventId, String name, String email, BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String userId = user.uid;

    CollectionReference registrations =
        FirebaseFirestore.instance.collection('registrations');

    await registrations.add({
      'eventId': eventId,
      'name': name,
      'email': email,
      'registeredAt': FieldValue.serverTimestamp(),
      'userId': userId,
    }).then((value) async {
      Fluttertoast.showToast(
        msg: "User Registered",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // Prompt user to send an email
      Fluttertoast.showToast(
        msg: "Email sent to your email address ${user.email}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
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
