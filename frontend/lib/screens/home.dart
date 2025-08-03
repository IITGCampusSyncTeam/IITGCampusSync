// import 'package:flutter/material.dart';
// import 'package:frontend/screens/event_screen.dart';
// import 'package:frontend/screens/login_options_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'cart_screen.dart';
// import 'login_screen.dart';
// import 'orders_screen.dart';
// import 'user_profile_screen.dart'; // Import the profile screen
//
// /// Home page with bottom navigation for Home, Clubs, Cart, and Orders.
// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);
//
//   @override
//   _HomeState createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//   // 0: Home, 1: Clubs, 2: Cart, 3: Orders
//   int _selectedIndex = 0;
//
//   // List of pages for each tab.
//   final List<Widget> _pages = [
//     const HomeContent(),
//     EventScreen(),
//     // const ClubsScreen(), // ClubsScreen has its own AppBar
//     const CartScreen(),
//
//     OrdersPage(),
//   ];
//
//   Future<void> _logout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear(); // Clear all user data
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (context) => const LoginOptionsScreen(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _selectedIndex == 0
//           ? AppBar(
//               title: const Text(
//                 "IITGSync",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               backgroundColor: Colors.blueAccent,
//               elevation: 3, // Soft shadow for depth
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.person), // Profile icon
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => UserProfileScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.logout),
//                   onPressed: () => _logout(context),
//                 ),
//               ],
//             )
//           : null, // No AppBar on Clubs, Cart, Orders
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         onTap: (index) => setState(() => _selectedIndex = index),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: "Home",
//           ),
//           BottomNavigationBarItem(
//             //TODO: replace with club screen
//             icon: Icon(Icons.group),
//             // label: "Clubs",
//             label: "events",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: "Cart",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.receipt_long),
//             label: "Orders",
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// The original home content displayed in the first tab.
// class HomeContent extends StatelessWidget {
//   const HomeContent({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: const [
//           Text(
//             "Welcome to IITGSync",
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16),
//           Text(
//             "Streamlining notifications, simplifying your life.",
//             style: TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
