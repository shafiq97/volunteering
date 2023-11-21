import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Load the user's profile data when the page is loaded
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await _firestore.collection('profiles').doc(user.uid).get();

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          _nameController.text = data['name'];
          _phoneNumberController.text = data['phoneNumber'];
          _ageController.text = data['age'];
          _idController.text = data['id'];
        }
      }
    } catch (e) {
      // Handle errors here
      print('Error loading profile data: $e');
    }
  }

  Future<void> saveProfileData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('profiles').doc(user.uid).set({
          'name': _nameController.text,
          'phoneNumber': _phoneNumberController.text,
          'age': _ageController.text,
          'id': _idController.text,
        });
      }
    } catch (e) {
      // Handle errors here
      print('Error saving profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      backgroundColor: Colors.pink,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              ),
              // TextFormField(
              //   controller: _idController,
              //   decoration: InputDecoration(
              //     labelText: 'ID',
              //     labelStyle: TextStyle(color: Colors.white),
              //   ),
              //   style: TextStyle(color: Colors.white),
              // ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Save or update the user's profile information to Firebase Firestore
                  saveProfileData();
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
