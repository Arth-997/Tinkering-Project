// lib/home.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart'; // Ensure you have this file for the LoginPage
import 'logs.dart';
import 'temppasskey.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Color(0xFF03A9F4), // Optional: Match the splash screen color
      ),
      body: Container(
        width: double.infinity, // Occupies the entire width of the screen
        height: double.infinity, // Occupies the entire height of the screen
        color: Colors.lightBlue[50], // Optional: Set a background color
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center all widgets vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center all widgets horizontally
          children: <Widget>[
            // Welcome image, centered at the top
            Image.asset(
              'assets/welcome.png',
              width: MediaQuery.of(context).size.width * 0.6, // 60% of screen width
              height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
              fit: BoxFit.contain, // Ensures the image maintains aspect ratio
            ),
            SizedBox(height: 40), // Space between image and first button

            // Generate Temp Passkey Button
            ElevatedButton(
              onPressed: () {
                // Navigate to GenerateTempPasskeyPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TempPasskeyPage()),
                );
              },
              child: Text('Generate Temp Passkey'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // Button size
                textStyle: TextStyle(fontSize: 16), // Button text size
              ),
            ),
            SizedBox(height: 20), // Space between buttons

            // View Logs Button
            ElevatedButton(
              onPressed: () {
                // Navigate to ViewLogsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EntryLogs()),
                );
              },
              child: Text('View Logs'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // Button size
                textStyle: TextStyle(fontSize: 16), // Button text size
              ),
            ),
            SizedBox(height: 20), // Space between buttons

            // Logout Button
            ElevatedButton(
              onPressed: () async {
                // Logout button to clear shared preferences and navigate to login page
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear all shared preferences
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false, // Prevent going back to HomePage
                );
              },
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red button for logout
                minimumSize: Size(200, 50), // Button size
                textStyle: TextStyle(fontSize: 16), // Button text size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
