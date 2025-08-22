import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/views/Blogging/BlogsMain.dart';
import 'package:habit_tracker/views/Login_Page.dart';
import 'dart:async';
import 'package:habit_tracker/views/MyHabits.dart';
import 'package:habit_tracker/views/my_progress.dart';
import 'package:habit_tracker/services/Firebase_AuthServices.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  String name = '';
  String motivationalLine = 'Shine your way!';
  final List<String> sliderImages = [
    'assets/images/HomePageImages/img.png',
    'assets/images/HomePageImages/img_1.png',
    'assets/images/HomePageImages/img_2.png',
    'assets/images/HomePageImages/img_3.png',
  ];

  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % sliderImages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['name'] ?? '';
          motivationalLine = data['motivational_line'] ?? motivationalLine;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDDDE6), Color(0xFF6A82FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              _buildGreetingCard(),
              SizedBox(height: 20),
              _buildImageSlider(),
              SizedBox(height: 20),
              Expanded(child: _buildActionCards()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Color(0xFF0F0E47)),
            onPressed: () => Navigator.pop(context),
          ),
          Spacer(),
          Text(
            'Habitué',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F0E47),
              fontSize: 28,
              letterSpacing: 0.5,
            ),
          ),
          Spacer(flex: 2),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );

            },
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Color(0xFFEDEBFD), Color(0xFFDAD0F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi $name 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333366)),
            ),
            SizedBox(height: 8),
            Text(
              motivationalLine,
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Color(0xFF5D5D8C)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return Center(
      child: Container(
        height: 180,
        child: AnimatedSwitcher(
          duration: Duration(seconds: 1),
          child: ClipRRect(
            key: ValueKey<String>(sliderImages[_currentIndex]),
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              sliderImages[_currentIndex],
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 0.9,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          _buildOptionCard(
            icon: Icons.check_circle_outline,
            title: 'Track Your Habits',
            subtitle: 'Start your day with goals!',
            onTap: ()
              {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => HabitMainPage()));
              },

          ),
          SizedBox(height: 16),
          _buildOptionCard(
            icon: Icons.bar_chart_rounded,
            title: 'View Progress',
            subtitle: 'Visualize your consistency',
            onTap: ()   {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ViewProgressScreen()));
            },

          ),
          SizedBox(height: 16),
          _buildOptionCard(
            icon: Icons.note_add_sharp,
            title: 'Personal Blogging',
            subtitle: 'Add your experiences ',
            onTap: ()   {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => BlogListScreen(uid: uid)));
            },

          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFF6A82FB).withOpacity(0.1),
              child: Icon(icon, color: Color(0xFF6A82FB), size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }
}
