import 'package:bookiee/Screens/BookListScreen.dart';
import 'package:bookiee/Screens/ConfirmedRequestsScreen.dart';
import 'package:bookiee/Screens/HomeScreen.dart';
import 'package:bookiee/Screens/LoginScreen.dart';
import 'package:bookiee/Screens/ProfileScreen.dart';
import 'package:bookiee/Screens/ShareBookScreen.dart';
import 'package:bookiee/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SearchOverlay.dart'; // Import the search overlay widget

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => HomeLayoutState();
}

class HomeLayoutState extends State<HomeLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;
  late Widget _homeScreenComponent;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _homeScreenComponent = HomeScreen();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email == null || email.isEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LoginScreen(),
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          _homeScreenComponent = BookListScreen();
          break;
        case 1:
          _homeScreenComponent = ShareBookScreen();
          break;
        case 2:
          _homeScreenComponent = HomeScreen();
          break;
        case 3:
          _homeScreenComponent = ConfirmedRequestsScreen();
          break;
        default:
          _homeScreenComponent = ProfileScreen();
          break;
      }
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MyApp(), // Redirect to main app entry point
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
      barrierDismissible: false, // Prevent the background from turning black
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            _scaffoldKey.currentState?.openDrawer();
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
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _confirmLogout(); // Show logout confirmation popup
              },
            ),
          ],
        ),
      ),
      body: _homeScreenComponent,
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
