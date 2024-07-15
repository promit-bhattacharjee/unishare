import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BookListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getBooks() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore.collection('books').get();
    return querySnapshot;
  }

  void onGetButtonPressed(
      String docId, String publisherEmail, BuildContext context) async {
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
        await FirebaseFirestore.instance.collection('bookRequests').add({
          'userEmail': "me@me.com",
          'bookId': docId,
          'status': 'requested',
          'publisherEmail': publisherEmail,
          'borrowPeriod': selectedDays,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book request sent successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send book request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
              child: Padding(
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
                                  width: double
                                      .infinity, // Ensures image stretches horizontally
                                  height:
                                      200, // Adjust height as needed for consistency
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                                      docId, data['userEmail'], context),
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
            );
          },
        );
      },
    );
  }
}
