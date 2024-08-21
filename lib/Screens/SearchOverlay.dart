import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchOverlay extends StatefulWidget {
  final TextEditingController controller;

  const SearchOverlay({required this.controller, Key? key}) : super(key: key);

  @override
  _SearchOverlayState createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  List<DocumentSnapshot> _searchResults = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_performSearch);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_performSearch);
    super.dispose();
  }

  void _performSearch() async {
    String query = widget.controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    setState(() {
      _searchResults = querySnapshot.docs;
    });
  }

  void _showBookDetails(DocumentSnapshot bookDoc) async {
    var book = bookDoc.data() as Map<String, dynamic>;
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
      await _requestBook(book, selectedDays);
    }
  }

  Future<void> _requestBook(Map<String, dynamic> book, int borrowPeriod) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail != null) {
        // Check for existing request
        QuerySnapshot existingRequests = await FirebaseFirestore.instance
            .collection('bookRequests')
            .where('userEmail', isEqualTo: userEmail)
            .where('bookData.publisherEmail', isEqualTo: book['publisherEmail'])
            .where('bookData.title', isEqualTo: book['title'])
            .where('status', isEqualTo: 'requested') // Add status check
            .get();

        if (existingRequests.docs.isEmpty) {
          // No existing request found, add the new request
          await FirebaseFirestore.instance.collection('bookRequests').add({
            'userEmail': userEmail,
            'bookData': book,
            'status': 'requested',
            'borrowPeriod': borrowPeriod,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Book request sent successfully!')),
          );
        } else {
          // Request already exists
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Book request already exists!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send book request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Image.asset(
              'assets/icons/banner.png', // Adjust the path as needed
              height: 50, // Adjust the height as needed
              width: 150, // Adjust the width as needed
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(
                left: 20.0), // Add space before the back button
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          elevation: 0, // Remove the shadow
          backgroundColor: Colors.transparent, // Transparent background
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              var book = _searchResults[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 4,
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(book['title']),
                  subtitle: Text(book['author']),
                  trailing: IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () => _showBookDetails(_searchResults[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
