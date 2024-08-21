import 'dart:io';
import 'dart:math';
import 'package:bookiee/Screens/HomeLayout.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShareBookScreen extends StatefulWidget {
  const ShareBookScreen({Key? key}) : super(key: key);

  @override
  State<ShareBookScreen> createState() => _ShareBookScreenState();
}

class _ShareBookScreenState extends State<ShareBookScreen> {
  final ImagePicker _picker = ImagePicker();
  final now = DateTime.now();
  File? _frontImage;
  File? _backImage;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  String _userEmail = ''; // To be populated with the current user's email

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  Future<void> _getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? 'user@example.com'; // Fallback email
      });
    }
  }

  Future<void> _pickImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  Future<void> _uploadBookDetails() async {
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add both front and back images.')),
      );
      return;
    }

    try {
      // Upload images to Firebase Storage
      String frontImageUrl = await _uploadFile(_frontImage!, 'front');
      String backImageUrl = await _uploadFile(_backImage!, 'back');

      // Save book details to Firestore
      await FirebaseFirestore.instance.collection('books').doc().set({
        'userEmail': _userEmail,
        'title': _titleController.text,
        'subject': _subjectController.text,
        'author': _authorController.text,
        'publisher': _publisherController.text,
        'course': _courseController.text,
        'frontImageUrl': frontImageUrl,
        'backImageUrl': backImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book details uploaded successfully!')),
      );

      // Clear all the controllers
      _titleController.clear();
      _subjectController.clear();
      _authorController.clear();
      _publisherController.clear();
      _courseController.clear();
      setState(() {
        _frontImage = null;
        _backImage = null;
      });

      // Reload the page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeLayout()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload book details: $e')),
      );
    }
  }

  Future<String> _uploadFile(File file, String fileName) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child(
            'book_images/${Random().nextInt(10000).toString() + now.toString() + _userEmail + Random().nextInt(100000).toString()}')
        .putFile(file);

    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Divider(thickness: 2, height: 1),
            SizedBox(height: 20),
            Text(
              "SHARE BOOK",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(4, 59, 92, 1),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_a_photo, size: 50),
                      onPressed: () {
                        if (_frontImage == null || _backImage == null) {
                          _pickImage(_frontImage == null);
                        }
                      },
                    ),
                    Text('ADD PHOTO'),
                  ],
                ),
                Column(
                  children: [
                    _frontImage == null
                        ? Container(
                            height: 100,
                            width: 80,
                            color: Colors.grey[300],
                            child: Icon(Icons.image, size: 50),
                          )
                        : Stack(
                            children: [
                              Image.file(
                                _frontImage!,
                                height: 100,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _frontImage = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                    Text('Front'),
                  ],
                ),
                Column(
                  children: [
                    _backImage == null
                        ? Container(
                            height: 100,
                            width: 80,
                            color: Colors.grey[300],
                            child: Icon(Icons.image, size: 50),
                          )
                        : Stack(
                            children: [
                              Image.file(
                                _backImage!,
                                height: 100,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _backImage = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                    Text('Back'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _publisherController,
              decoration: InputDecoration(
                labelText: 'Publisher',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _courseController,
              decoration: InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: _uploadBookDetails,
              child: Text(
                'PUBLISH',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
