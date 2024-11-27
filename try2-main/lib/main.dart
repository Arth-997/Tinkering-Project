import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'page/login.dart';  // Ensure correct paths
import 'page/home.dart';   // Ensure correct paths
// import 'page/test.dart'; // Uncomment if needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Method to check if the user is already logged in
  Future<bool> _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    // If userId is null or an empty string, consider user as logged out
    return userId != null && userId.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        useMaterial3: true, // Enable Material 3
        primaryColor: Colors.lightBlue,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.blueAccent, // Replaces accentColor
        ),
        scaffoldBackgroundColor: Colors.lightBlue[50],
        appBarTheme: const AppBarTheme(
          color: Colors.lightBlue, // AppBar color
          elevation: 0, // Removes AppBar shadow
          centerTitle: true, // Centers the title
          titleTextStyle: TextStyle(
            color: Colors.white, // Title text color
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          toolbarTextStyle: TextStyle(
            color: Colors.white, // Toolbar text color
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue, // Replaces primary
            foregroundColor: Colors.white, // Replaces onPrimary
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none, // Removes the default border
          ),
          prefixIconColor: Colors.lightBlue,
          hintStyle: TextStyle(color: Colors.grey[700]),
        ),
        textTheme: const TextTheme(
          // Updated from headline6 to headlineSmall
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
          // Add other text styles as needed
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkLogin(),
        builder: (context, snapshot) {
          // While waiting for SharedPreferences to load
          if (snapshot.connectionState == ConnectionState.waiting) {
            return WelcomeScreen(); // Show WelcomeScreen instead of LoadingScreen
          }

          // Navigate based on whether the user is logged in or not
          if (snapshot.hasData && snapshot.data == true) {
            return HomePage();  // If user is logged in, go to HomePage
          } else {
            return LoginPage();  // If no userId is found, go to LoginPage
          }
        },
      ),
    );
  }
}

// Updated Welcome Screen Widget
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF03A9F4), // Set background color to #03a9f4
      body: Center(
        child: Column(
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
