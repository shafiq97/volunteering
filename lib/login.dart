import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:volunteering/main.dart';
import 'package:volunteering/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _navigateToRegisterPage() {
    // Add navigation logic to your registration page here
    // For example:
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      backgroundColor: Colors.pink,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Volunteer App',
              style: TextStyle(
                fontSize: 36, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle:
                    TextStyle(color: Colors.white), // Set label text color
              ),
              style: TextStyle(color: Colors.white), // Set input text color
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle:
                    TextStyle(color: Colors.white), // Set label text color
              ),
              style: TextStyle(color: Colors.white), // Set input text color
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 10),
            GestureDetector(
              onTap:
                  _navigateToRegisterPage, // Navigate to the registration page
              child: Text(
                'Register', // This is your "Register" link
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
