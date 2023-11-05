import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:volunteering/activity.dart';
import 'package:volunteering/activity_registration.dart';
import 'package:volunteering/firebase_options.dart';
import 'package:volunteering/login.dart';
import 'package:volunteering/profile.dart';
import 'package:volunteering/registered_activity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  // Initialize Firebase App Check with the debug provider
  if (kDebugMode) {
    await FirebaseAppCheck.instance.activate();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.pink, // Customize your theme
      ),
      home: LoginPage(), // Set the initial screen to LoginScreen
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Keep track of the selected tab index

  // List of pages/screens for each tab
  final List<Widget> _pages = [
    ActivityPage(),
    ActivityPage(),
    ProfilePage(),
    CreateEventPage(),
  ];

  // Callback when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<String> _getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc['role'] ?? 'volunteer';
    }
    return 'volunteer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteering'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pink,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Registered Event'),
              onTap: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => RegisteredActivity()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut(); // This logs the user out
                // Navigate to the login page and remove all routes below from the stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  ModalRoute.withName('/'),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // Display the selected page
      floatingActionButton: FutureBuilder<String>(
        future: _getUserRole(), // here we get the role of the user
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // You can show a loading indicator while waiting for the data
            return SizedBox();
          } else if (snapshot.hasError) {
            // If we run into an error, we can handle it here
            return SizedBox();
          } else if (snapshot.data == 'organizer') {
            // Only show the FAB if the role is organizer
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEventPage()),
                );
              },
              child: Icon(Icons.add),
            );
          } else {
            // Return an empty container if the user is not an organizer
            return SizedBox();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink, // Customize the selected tab color
        onTap: _onItemTapped,
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Search Screen'),
    );
  }
}
