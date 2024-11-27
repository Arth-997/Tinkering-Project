// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore package

// class EntryLogs extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Firestore Entries')),
//       body: StreamBuilder<QuerySnapshot>(
//         // Fetch the top 10 documents from Firestore ordered by timestamp
//         stream: FirebaseFirestore.instance
//             .collection('1234')  // Replace with your collection name
//             .orderBy('timestamp', descending: true)
//             .limit(10)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           final entries = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: entries.length,
//             itemBuilder: (context, index) {
//               var entry = entries[index];
//               bool succAuth = entry['succAuth'];  // Assuming succAuth is a bool
//               DateTime timestamp = entry['timestamp'].toDate();  // Assuming timestamp is a Firestore Timestamp

//               return Container(
//                 padding: EdgeInsets.all(10),
//                 margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                 color: succAuth ? Colors.green : Colors.red,  // Color based on succAuth
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Entry: ${entry['succAuth']}',  // Replace with your field name
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       'Time: ${timestamp.toLocal().toString()}',  // Displaying local time
//                       style: TextStyle(fontSize: 12, color: Colors.white),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: FirestoreDisplay(),
//   ));
// }
