import 'package:flutter/material.dart';
import 'package:my_insta/screens/home/home_screen.dart';
import 'package:my_insta/screens/home/search_screen.dart';
import 'package:my_insta/screens/post/media_selection_screen.dart';
import 'package:my_insta/screens/account/user_list_screen.dart';
import '../account/account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChoicesScreen(selectedIndex: _selectedIndex),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Color(0xFF000000), // Deep black
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            elevation: 0, // Remove shadow
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Activity'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ));
  }
}

class ChoicesScreen extends StatelessWidget {
  final int selectedIndex;

  const ChoicesScreen({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedIndex,
      children: [
        HomeScreen(),
        SearchScreen(),
        MediaSelectionScreen(
          screen: 'NewPostScreen',
        ),
        UsersListScreen(),
        AccountScreen(), // Profile Page
      ],
    );
  }
}
