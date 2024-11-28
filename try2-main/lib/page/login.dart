import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'signup.dart'; // Ensure you have this page created

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Initialize TextEditingControllers for input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  // Method to handle user login
  Future<void> _login() async {
    // Validate input fields
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to log in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Display a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful! Welcome ${userCredential.user?.email}'),
          backgroundColor: Colors.green,
        ),
      );

      // Store user ID in SharedPreferences
      String uid = userCredential.user?.uid ?? '';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', uid);

      // Navigate to HomePage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle login errors with user-friendly messages
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else {
        message = 'Login failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      // Handle any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      print("Login error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is removed from the widget tree
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color is set via ThemeData in main.dart
      body: SingleChildScrollView(
        // Allows the content to scroll if it overflows the screen
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Center the content vertically
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60), // Top padding
              // Logo
              Image.asset(
                'assets/logo.png',
                height: 150, // Adjust the size as needed
              ),
              SizedBox(height: 20), // Spacing between logo and title

              // Title
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),

              // Subtitle
              Text(
                'Sign in to access your account',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              SizedBox(height: 15),

              // Password TextField
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity, // Makes the button full-width
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              ),
              SizedBox(height: 20),

              // Navigation to SignupPage
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: 'New Member? ',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Register now',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 60), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
