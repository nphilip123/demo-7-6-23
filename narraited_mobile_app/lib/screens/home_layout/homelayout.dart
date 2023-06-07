import 'package:flutter/material.dart';
// import 'package:narraited_mobile_app/screens/chat_screen/chat_screen.dart';
import 'package:narraited_mobile_app/screens/profile_screen/profile_screen.dart';
// import 'package:provider/provider.dart';

// import '../../provider/chatmessages.dart';
// import '../../utilities/icons/app_icons.dart';
import '../home_screen/home_screen.dart';

class Homelayout extends StatefulWidget {
  const Homelayout({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomelayoutState createState() => _HomelayoutState();
}

class _HomelayoutState extends State<Homelayout> {
  var currentIndex = 0;
  final screen = [
    // ignore: prefer_const_constructors
    HomeScreen(),
    // ignore: prefer_const_constructors
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screen,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xff3c83cb),
        unselectedItemColor: const Color(0xff97A2B0),
        currentIndex: currentIndex,
        onTap: (value) => setState(() {
          currentIndex = value;
        }),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 30,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () {
      //       // Navigator.push(context, MaterialPageRoute(builder: (context) {
      //       //   // ignore: prefer_const_constructors
      //       //   return ChatScreen();
      //       // }));
      //       // Provider.of<ChatMessages>(context, listen: false).reset();
      //       // debugPrint("cleared chat");
      //     },
      //     backgroundColor: const Color(0xff3c83cb),
      //     child: const Icon(
      //         HomelayoutIcons.mic,
      //         color: Colors.white,
      //       ),
      //     ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
