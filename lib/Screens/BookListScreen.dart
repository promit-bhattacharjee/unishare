import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<QuerySnapshot<Map<String, dynamic>>> getBooks() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore.collection('books').get();
    return querySnapshot;
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  void onGetButtonPressed(Map<String, dynamic> bookData, String publisherEmail,
      BuildContext context) async {
    int? selectedDays = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Borrow Period'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 7),
              child: const Text('7 Days'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 15),
              child: const Text('15 Days'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 30),
              child: const Text('30 Days'),
            ),
          ],
        );
      },
    );

    if (selectedDays != null) {
      try {
        // Load the user's email from SharedPreferences
        String? userEmail = await getUserEmail();

        if (userEmail != null) {
          // Add the book request to Firestore
          await FirebaseFirestore.instance.collection('bookRequests').add({
            'userEmail': userEmail, // Use the email from SharedPreferences
            'bookData': bookData, // Store the entire book data
            'status': 'requested',
            'publisherEmail': publisherEmail,
            'borrowPeriod': selectedDays,
          });

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Book request sent successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send book request: $e')),
        );
      }
    }
  }

  void onDeleteBook(String docId, BuildContext context) async {
    try {
      await _firestore.collection('books').doc(docId).delete();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book deleted successfully!')),
      );

      // Refresh the page
      _refreshIndicatorKey.currentState?.show();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete book: $e')),
      );
    }
  }

  void showDeleteConfirmationDialog(String docId, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Book'),
          content: Text('Are you sure you want to delete this book?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
                onDeleteBook(docId, context); // Delete the book
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // Close the confirmation dialog
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to fetch books'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> doc =
                  snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data()!;
              String docId = doc.id; // Get the document ID

              return Card(
                elevation: 4,
                color: Color.fromRGBO(255, 176, 0, 0.4),
                margin: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: CarouselSlider(
                                  items: [
                                    if (data['frontImageUrl'] != null)
                                      Image.network(
                                        data['frontImageUrl'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 200,
                                      ),
                                    if (data['backImageUrl'] != null)
                                      Image.network(
                                        data['backImageUrl'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 200,
                                      ),
                                  ],
                                  options: CarouselOptions(
                                    enlargeCenterPage: true,
                                    enableInfiniteScroll: false,
                                    initialPage: 0,
                                    viewportFraction: 1,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Title: ${data['title']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text('Author: ${data['author']}'),
                                    Text('Subject: ${data['subject']}'),
                                    Text('Publisher: ${data['publisher']}'),
                                    Text('Course: ${data['course']}'),
                                    SizedBox(height: 8),
                                    Center(
                                      child: ElevatedButton.icon(
                                        onPressed: () => onGetButtonPressed(
                                            data, data['userEmail'], context),
                                        icon: Icon(Icons.get_app),
                                        label: Text('Get'),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.green),
                                          minimumSize:
                                              MaterialStateProperty.all<Size>(
                                                  Size(150, 40)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FutureBuilder<String?>(
                        future: getUserEmail(),
                        builder: (context, emailSnapshot) {
                          if (emailSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (emailSnapshot.hasError ||
                              !emailSnapshot.hasData) {
                            return Container();
                          }

                          String? userEmail = emailSnapshot.data;
                          bool showDeleteButton =
                              data['userEmail'] == userEmail;

                          return showDeleteButton
                              ? IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => showDeleteConfirmationDialog(
                                      docId, context),
                                )
                              : Container();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
