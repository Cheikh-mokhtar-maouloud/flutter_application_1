import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/messages_screen.dart';
import 'package:flutter_application_1/screens/schedule_screen.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';

class NavBarRoots extends StatefulWidget {
  @override
  State<NavBarRoots> createState() => _NavBarRootsState();
}

class _NavBarRootsState extends State<NavBarRoots> {
  int _selectedIndex = 0;

  // Introduce a cache for each screen
  final Map<int, Widget> _screenCache = {};

  @override
  Widget build(BuildContext context) {
    // Return cached screen if it exists, otherwise create and cache it
    Widget getCachedScreen(int index) {
      if (_screenCache.containsKey(index)) {
        return _screenCache[index]!;
      } else {
        Widget newScreen;
        switch (index) {
          case 0:
            newScreen = HomeScreen();
            break;
          case 1:
            newScreen = MessagesScreen();
            break;
          case 2:
            newScreen = ScheduleScreen();
            break;
          case 3:
            newScreen = SettingScreen();
            break;
          default:
            newScreen = HomeScreen(); // Default fallback
            break;
        }
        _screenCache[index] = newScreen; // Cache the screen
        return newScreen;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: getCachedScreen(_selectedIndex),
      bottomNavigationBar: Container(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF7165D6),
          unselectedItemColor: Colors.black26,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: "Accueil"),
            BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.chat_bubble_text_fill,
                ),
                label: "Messages"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                label: "Rendez-vous"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "paramètre"),
          ],
        ),
      ),
    );
  }
}
