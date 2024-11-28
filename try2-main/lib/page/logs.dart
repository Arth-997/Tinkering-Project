import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date and time

class EntryLogs extends StatefulWidget {
  @override
  _EntryLogsState createState() => _EntryLogsState();
}

class _EntryLogsState extends State<EntryLogs> {
  // Method to fetch data from Firestore, ordered by timestamp descending
  Future<List<Map<String, dynamic>>> _fetchLogs() async {
    try {
      // Fetch all documents from the Firestore collection '1234', ordered by 'timestamp'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('1234')
          .orderBy('timestamp', descending: true) // Order by timestamp descending
          .get();

      // Map Firestore documents to a list of maps
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Convert Firestore timestamp to DateTime
        DateTime timestamp = DateTime.parse(data['timestamp']);

        // Convert timestamp to IST
        DateTime istTime = timestamp.add(Duration(hours: 5, minutes: 30));

        // Format time of day and date in DD/MM/YY
        String timeOfDay = DateFormat('hh:mm:ss a').format(istTime);
        String date = DateFormat('dd/MM/yy').format(istTime);

        return {
          'succAuth': data['succAuth'],
          'timeOfDay': timeOfDay,
          'date': date,
        };
      }).toList();
    } catch (e) {
      print("Error fetching logs: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Logs'),
        backgroundColor: Color(0xFF03A9F4),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLogs(), // Fetch logs data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching logs'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No logs found'));
          } else {
            // Data exists, display logs in a ListView
            List<Map<String, dynamic>> logs = snapshot.data!;
            return ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                bool isSuccess = log['succAuth'];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(
                      isSuccess ? Icons.lock_open : Icons.lock_outline,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      isSuccess ? 'Authorized Entry' : 'Unauthorized Access',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      'Time: ${log['timeOfDay']}\nDate: ${log['date']}',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
