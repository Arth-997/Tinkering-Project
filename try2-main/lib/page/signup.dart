import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Initialize TextEditingControllers for input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  // Method to handle user signup
  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Process Referral ID: Check if it matches "hello" and convert to "1234"
      String referralId = _referralController.text.trim();
      if (referralId == "uY5lHK3FWzy0TyGnnY/7gA==") {
        referralId = "1234";
      }

      // Create a new user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store additional user information (e.g., referral ID) in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': _emailController.text.trim(),
        'referralId': referralId, // Use the processed referralId
      });

      // Store user ID in SharedPreferences
      String uid = userCredential.user?.uid ?? '';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', uid);

      // Navigate to HomePage after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle signup errors with user-friendly messages
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = 'Signup failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Handle any other errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred.')));
      print("Error during signup: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    // Dispose controllers to free up resources
    _emailController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color to light blue
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlue, // Match AppBar color with background
        elevation: 0, // Remove AppBar shadow for a cleaner look
        centerTitle: true, // Center the title
      ),
      body: SingleChildScrollView(
        // Allows the content to scroll if it overflows the screen
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Stretch to fill the width
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add the logo from assets/logo.png
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 150, // Adjust the size as needed
                ),
              ),
              SizedBox(height: 20), // Spacing between logo and instructions

              // Add short instructions for the user
              Text(
                'Get Started by creating a free account',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30), // Spacing between instructions and input fields

              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Valid Email',
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15),

              // Password TextField
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Strong Password',
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 15),

              // Referral ID TextField (Optional)
              TextField(
                controller: _referralController,
                decoration: InputDecoration(
                  hintText: 'Product ID',
                  labelText: 'Product ID',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Sign Up Button
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue, // Button color
                        foregroundColor: Colors.white, // Text color
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),
              SizedBox(height: 20),

              // Navigation to Login Page
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already a member? ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
