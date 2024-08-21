import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingRequestsScreen extends StatefulWidget {
  @override
  _BookingRequestsScreenState createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserEmail(); // Load the user email when the screen initializes
  }

  // Load the email from SharedPreferences
  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail =
          prefs.getString('email') ?? ''; // Replace 'email' with your key
    });
  }

  // Fetches all requests for the current user with 'requested' status
  Future<List<Map<String, dynamic>>> getMyRequests() async {
    if (_userEmail.isEmpty) {
      return [];
    }

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('bookRequests')
        .where('userEmail', isEqualTo: _userEmail)
        .where('status', isEqualTo: 'requested') // Filter by 'requested' status
        .get();

    List<Map<String, dynamic>> requests = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      data['docId'] = doc.id;
      requests.add(data);
    }

    return requests;
  }

  // Deletes a specific request by its document ID
  Future<void> deleteRequest(String docId) async {
    await _firestore.collection('bookRequests').doc(docId).delete();
  }

  // Shows detailed information about a request in an AlertDialog
  void showRequestDetails(Map<String, dynamic> request) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request Status: ${request['status']}'),
                Text(
                    'Borrow Period: ${request['borrowPeriod'].toString()} days'),
                SizedBox(height: 10),
                Text('Book Data:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (request['frontImageUrl'] != null)
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(request['frontImageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (request['backImageUrl'] != null)
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(request['backImageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text('Title: ${request['bookData']['title']}'),
                Text('Author: ${request['bookData']['author']}'),
                Text('Publisher: ${request['bookData']['publisher']}'),
                Text('Subject: ${request['bookData']['subject']}'),
                Row(
                  children: [
                    Text("Front Image :  "),
                    if (request['bookData']['frontImageUrl'] != null)
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                request['bookData']['frontImageUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text("Back Image :  "),
                    if (request['bookData']['backImageUrl'] != null)
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                request['bookData']['backImageUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                Text('Request Data:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Requests'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getMyRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to fetch booking requests'));
          }

          List<Map<String, dynamic>> requests = snapshot.data ?? [];

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['bookData']['title'] ?? 'Unknown',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => showRequestDetails(request),
                        child: Text('Details'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
