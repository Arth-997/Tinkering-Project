// lib/welcome.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'home.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start the timer as soon as the WelcomeScreen is displayed
    Timer(Duration(seconds: 800), _navigateToNext); // Changed to 3 seconds
  }

  // Method to decide where to navigate next
  void _navigateToNext() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null && userId.isNotEmpty) {
      // User is already logged in, navigate to HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // User is not logged in, navigate to LoginPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF03A9F4), // Set background color to #03a9f4
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensures Column takes minimal vertical space
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the secured.png image
            Image.asset(
              'assets/secured.png',
              width: 150, // Adjust the size as needed
              height: 150,
            ),
            SizedBox(height: 20),
            // Optional: Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
