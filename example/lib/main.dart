import 'package:animated_nav_bar/animated_nav_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Nav Bar Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Nav Bar Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          Container(
            color: Colors.blue[100],
            child: const Center(
              child: Text("Home Page", style: TextStyle(fontSize: 24)),
            ),
          ),
          Container(
            color: Colors.red[100],
            child: const Center(
              child: Text("Search Page", style: TextStyle(fontSize: 24)),
            ),
          ),
          Container(
            color: Colors.green[100],
            child: const Center(
              child: Text("Notifications Page", style: TextStyle(fontSize: 24)),
            ),
          ),
          Container(
            color: Colors.purple[100],
            child: const Center(
              child: Text("Profile Page", style: TextStyle(fontSize: 24)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedNavBar(
        selectedIndex: _selectedIndex,
        iconSize: 28,
        backgroundColor: Colors.black87,
        indicatorColor: Colors.white24,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        pageController: _pageController,
        icons: const [
          Icons.home,
          Icons.search,
          Icons.notifications,
          Icons.person,
        ],
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}
