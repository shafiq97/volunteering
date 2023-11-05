import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:volunteering/activity.dart';
import 'package:volunteering/activity_registration.dart';
import 'package:volunteering/firebase_options.dart';
import 'package:volunteering/login.dart';
import 'package:volunteering/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase 
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
    SearchScreen(),
    ProfilePage(),
    CreateEventPage(),
  ];

  // Callback when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              leading: const Icon(Icons.add_circle),
              title: const Text('Create Activity'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEventPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // Display the selected page
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventPage()),
          );
        },
        child: Icon(Icons.add),
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
