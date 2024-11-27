import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TempPasskeyPage extends StatefulWidget {
  @override
  _TempPasskeyPageState createState() => _TempPasskeyPageState();
}

class _TempPasskeyPageState extends State<TempPasskeyPage> {
  // Initialize a list of TextEditingControllers for the passcode fields
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  String _passcode = '';

  // Method to combine the 4 digits into a single passcode string
  void setPasscode() async {
    String input = _controllers.map((controller) => controller.text).join();
    if (input.length == 4 && RegExp(r'^[0-9]+$').hasMatch(input)) {
      setState(() {
        _passcode = input;
      });
      print("Passcode set to: $_passcode");

      // Get current timestamp and format it
      String formattedTimestamp = DateTime.now().toUtc().toIso8601String();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      FirebaseFirestore db = FirebaseFirestore.instance;
      String refId = '';

      if (userId != null) {
        try {
          DocumentSnapshot userDoc = await db.collection("users").doc(userId).get();
          if (userDoc.exists) {
            refId = userDoc.get('referralId');
          } else {
            print("User document does not exist.");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User not found.')),
            );
            return;
          }
        } catch (e) {
          print("Error getting user document: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching user data.')),
          );
          return;
        }

        try {
          await db.collection("info").doc(refId).update({
            'passkey': input, // Store the passcode
            'passTime': formattedTimestamp, // Store the formatted timestamp
          });
          print("Referral ID updated successfully!");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Passcode set successfully!')),
          );
        } catch (e) {
          print("Error updating Referral ID: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error setting passcode.')),
          );
        }
      } else {
        print("User ID not found in SharedPreferences.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in.')),
        );
      }
    } else {
      print("Please enter a valid 4-digit passcode");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 4-digit passcode')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is removed from the widget tree to free up resources
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color is set via ThemeData in main.dart
      appBar: AppBar(
        title: Text(
          "Temp Passkey Page",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlue, // Match AppBar color with main theme
        elevation: 0, // Remove AppBar shadow for a cleaner look
      ),
      body: SingleChildScrollView(
        // Allows the content to scroll if it overflows the screen
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Center the content vertically
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add the logo from assets/logo.png
              Image.asset(
                'assets/logo.png',
                height: 100, // Adjust the size as needed
              ),
              SizedBox(height: 20), // Spacing between logo and instructions

              // Add short instructions for the user
              Text(
                'Enter your 4-digit temporary passcode below:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30), // Spacing between instructions and passcode fields

              // Passcode input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _controllers[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1, // Limit each box to 1 digit
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: "", // Hides the length counter
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // Optional: Add focused border color
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.lightBlue),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 3) {
                          FocusScope.of(context).nextFocus(); // Move to the next field
                        }
                      },
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),

              // Set Passcode button
              SizedBox(
                width: double.infinity, // Make the button full-width
                child: ElevatedButton(
                  onPressed: setPasscode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue, // Replaces primary
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Set Passcode",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Display the set passcode or a message if not set
              Text(
                _passcode.isNotEmpty
                    ? "Passcode set to: $_passcode"
                    : "No passcode set yet",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
