import 'package:bookiee/Screens/BookListScreen.dart';
import 'package:bookiee/Screens/BookingRequestsScreen.dart';
import 'package:bookiee/Screens/HomeScreen.dart';
import 'package:bookiee/Screens/ProfileScreen.dart';
import 'package:bookiee/Screens/ShareBookScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});
  @override
  State<HomeLayout> createState() => HomeLayoutState();
}

class HomeLayoutState extends State<HomeLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;
  Widget HomeScreenComponent = HomeScreen();

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Index 0: Home', style: optionStyle),
    Text('Index 1: Business', style: optionStyle),
    Text('Index 2: School', style: optionStyle),
    Text('Index 3: Message', style: optionStyle),
    Text('Index 4: Profile', style: optionStyle),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        HomeScreenComponent = HomeScreen();
      } else if (_selectedIndex == 1) {
        HomeScreenComponent = ShareBookScreen();
      } else if (_selectedIndex == 0) {
        HomeScreenComponent = BookListScreen();
      } else if (_selectedIndex == 3) {
        HomeScreenComponent = BookingRequestsScreen();
      } else {
        HomeScreenComponent = ProfileScreen();
      }
      print(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assigning a GlobalKey to the Scaffold
      appBar: AppBar(
        title: Center(
          child: Image(
            image: AssetImage("assets/icons/banner.png"),
            height: 100,
            width: 200,
          ),
        ),
        leading: IconButton(
          icon: Image.asset(
            "assets/icons/menu.png",
            width: 24,
            height: 24,
          ),
          onPressed: () {
            _scaffoldKey.currentState!
                .openDrawer(); // Access ScaffoldState directly
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/icons/menu_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              accountName: Text("Username"),
              accountEmail: Text("user@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/icons/menu_icon.png"),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close drawer and navigate to home
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close drawer and navigate to settings
              },
            ),
            // Add more list tiles as needed
          ],
        ),
      ),
      body: HomeScreenComponent,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(0, 0, 0, 1),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf),
            label: "PDF",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: "Books",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Message",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        onTap: _onItemTapped,
      ),
    );
  }
}
