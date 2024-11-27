import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryLogs extends StatefulWidget {
  @override
  _EntryLogsState createState() => _EntryLogsState();
}

class _EntryLogsState extends State<EntryLogs> {
  String? refId;

  @override
  void initState() {
    super.initState();
    _fetchReferralId();
  }

  Future<void> _fetchReferralId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId != null) {
        FirebaseFirestore db = FirebaseFirestore.instance;

        DocumentSnapshot userDoc = await db.collection("users").doc(userId).get();
        if (userDoc.exists) {
          setState(() {
            refId = userDoc.get('referralId');
          });
        } else {
          print("User document does not exist.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found.')),
          );
        }
      } else {
        print("User ID not found in SharedPreferences");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in.')),
        );
      }
    } catch (e) {
      print("Error fetching referral ID: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching referral ID.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color is set via ThemeData in main.dart
      appBar: AppBar(
        title: Text(
          "Entry Logs",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Allows the content to scroll if it overflows the screen
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Stretch to fill the width
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 100, // Adjust the size as needed
                ),
              ),
              SizedBox(height: 20), // Spacing between logo and instructions

              // Instructions
              Text(
                'Here are your recent entry logs:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30), // Spacing between instructions and logs

              // Display the logs or a message if no logs are found
              refId == null
                  ? Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(refId!)
                          .orderBy('timestamp', descending: true) // Order by the 'timestamp' field in descending order
                          .limit(100)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error fetching logs.',
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No entry logs found.',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          );
                        }

                        final entries = snapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true, // Important to prevent unbounded height
                          physics: NeverScrollableScrollPhysics(), // Disable inner scrolling
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            var entry = entries[index];
                            bool succAuth = entry['succAuth'];
                            String timestamp = entry['timestamp'];

                            return Card(
                              color: succAuth ? Colors.green[400] : Colors.red[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Entry: ${succAuth ? "Success" : "Failure"}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Document ID: ${entry.id}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Timestamp: $timestamp',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
