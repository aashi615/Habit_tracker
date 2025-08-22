import 'package:flutter/material.dart';
import 'package:habit_tracker/views/My%20Habits/Daily_Goals.dart';
import 'package:habit_tracker/views/My%20Habits/LongTerm_Goals.dart';
import 'package:habit_tracker/views/My%20Habits/short_term_goals.dart';

class HabitMainPage extends StatelessWidget {
  const HabitMainPage({super.key});

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  // Heading
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0,top: 10.0),
                    child: Text(
                      "Your Habits",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F0E47),
                      ),
                    ),
                  ),


                    Padding(
                      padding: const EdgeInsets.only(left:15.0),
                      child: Text(
                        "Set, track & conquer your goals 🚀",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),

                  // Image
                  Center(
                    child: Image.asset(
                      'assets/images/habitsImages/goal.png',
                      height: 230,
                      width: 400,
                    ),
                  ),


                  // Cards
                  HabitTypeCard(
                    title: 'Long Term Goals',
                    subtitle: 'Track your big dreams',
                    icon: Icons.flag_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LongTermGoalScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  HabitTypeCard(
                    title: 'Short Term Goals',
                    subtitle: 'Break it into milestones',
                    icon: Icons.bolt_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WeeklyHabitsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  HabitTypeCard(
                    title: 'Daily Habits',
                    subtitle: 'Build daily routine with timer',
                    icon: Icons.access_time_filled_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DailyHabitsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HabitTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const HabitTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFF6A82FB).withOpacity(0.15),
              child: Icon(icon, color: Color(0xFF6A82FB), size: 28),
            ),
            SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
