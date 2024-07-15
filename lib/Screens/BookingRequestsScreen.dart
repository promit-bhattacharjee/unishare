import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRequestsScreen extends StatefulWidget {
  @override
  _BookingRequestsScreenState createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userEmail = "me@me.com"; // Replace with the actual user email

  Future<List<Map<String, dynamic>>> getMyRequests() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('bookRequests')
        .where('userEmail', isEqualTo: _userEmail)
        .get();
    List<Map<String, dynamic>> requests = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      data['docId'] = doc.id;

      DocumentSnapshot<Map<String, dynamic>> bookSnapshot =
          await _firestore.collection('books').doc(data['bookId']).get();
      data['bookTitle'] = bookSnapshot.data()?['title'] ?? 'Unknown';

      requests.add(data);
    }

    return requests;
  }

  Future<void> deleteRequest(String docId) async {
    await _firestore.collection('bookRequests').doc(docId).delete();
  }

  void showRequestDetails(Map<String, dynamic> request) async {
    DocumentSnapshot<Map<String, dynamic>> bookSnapshot =
        await _firestore.collection('books').doc(request['bookId']).get();
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await _firestore.collection('users').doc(request['userEmail']).get();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Book Title: ${request['bookTitle']}'),
                Text('Request Status: ${request['status']}'),
                Text('Borrow Period: ${request['borrowPeriod']} days'),
                SizedBox(height: 10),
                Text('Book Data:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Title: ${bookSnapshot.data()?['title']}'),
                Text('Author: ${bookSnapshot.data()?['author']}'),
                SizedBox(height: 10),
                Text('User Data:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Name: ${userSnapshot.data()?['name']}'),
                Text('Email: ${userSnapshot.data()?['email']}'),
                SizedBox(height: 10),
                Text('Request Data:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Doc ID: ${request['docId']}'),
                Text('Publisher Email: ${request['publisherEmail']}'),
              ],
            ),
          ),
          actions: [
            if (request['status'] == 'requested')
              TextButton(
                onPressed: () {
                  deleteRequest(request['docId']);
                  Navigator.of(context).pop();
                  setState(() {}); // Refresh the list
                },
                child: Text('Cancel Request'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getMyRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to fetch booking requests'));
        }

        List<Map<String, dynamic>> requests = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Requester Email')),
                DataColumn(label: Text('Book Title')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: requests
                  .map(
                    (request) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text(request['userEmail'] ?? '')),
                        DataCell(Text(request['bookTitle'] ?? '')),
                        DataCell(Text(request['status'] ?? '')),
                        DataCell(Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => showRequestDetails(request),
                              child: Text('Details'),
                              style: ElevatedButton.styleFrom(),
                            ),
                          ],
                        )),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
