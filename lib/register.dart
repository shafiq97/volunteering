import 'package:flutter/material.dart';
import 'package:volunteering/login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register() {
    // Add your registration logic here
  }

  void _navigateToLoginPage() {
    // Add navigation logic to your login page here
    // For example:
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
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
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _navigateToLoginPage, // Navigate to the login page
              child: Text(
                'Login', // This is your "Login" link
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
