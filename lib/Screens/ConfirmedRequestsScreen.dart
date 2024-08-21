import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmedRequestsScreen extends StatefulWidget {
  @override
  _ConfirmedRequestsScreenState createState() =>
      _ConfirmedRequestsScreenState();
}

class _ConfirmedRequestsScreenState extends State<ConfirmedRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('email') ?? '';
    });
  }

  Future<List<Map<String, dynamic>>> getConfirmedRequests() async {
    if (_userEmail.isEmpty) {
      return [];
    }

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('bookRequests')
        .where('userEmail', isEqualTo: _userEmail)
        .where('status', isEqualTo: 'confirmed')
        .get();

    List<Map<String, dynamic>> confirmedRequests = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      data['docId'] = doc.id;
      confirmedRequests.add(data);
    }

    return confirmedRequests;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getConfirmedRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to fetch confirmed requests'));
        }

        List<Map<String, dynamic>> confirmedRequests = snapshot.data ?? [];

        if (confirmedRequests.isEmpty) {
          return Center(child: Text('No confirmed requests found.'));
        }

        return ListView.builder(
          itemCount: confirmedRequests.length,
          itemBuilder: (context, index) {
            var request = confirmedRequests[index];
            return Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request #${index + 1}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    if (request['frontImageUrl'] != null)
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(request['frontImageUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    SizedBox(height: 10),
                    Text('Title: ${request['bookData']['title']}'),
                    Text('Author: ${request['bookData']['author']}'),
                    Text('Publisher: ${request['bookData']['publisher']}'),
                    Text('Subject: ${request['bookData']['subject']}'),
                    Text('Borrow Period: ${request['borrowPeriod']} days'),
                    Text('Pickup Phone: ${request['pickupPhone']}'),
                    Text('Pickup Place: ${request['pickupPlace']}'),
                    Text('Pickup Time: ${request['pickupTime']}'),
                    Text('Publisher Email: ${request['publisherEmail']}'),
                    SizedBox(height: 10),
                    Text('Status: ${request['status']}'),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
