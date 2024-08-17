import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final VoidCallback onTap;
  final VoidCallback settingsTapped;
  final int timeSpent;
  final int timeGoal;
  final bool habitStarted;

  const HabitTile({
    Key? key,
    required this.habitName,
    required this.onTap,
    required this.settingsTapped,
    required this.timeSpent,
    required this.timeGoal,
    required this.habitStarted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double percentCompleted = timeSpent / (timeGoal * 60);

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Stack(
                      children: [
                        CircularPercentIndicator(
                          radius: 25,
                          lineWidth: 5.0,
                          percent: percentCompleted,
                          center: Container(),
                          progressColor: Colors.blue,
                        ),
                        Center(
                          child: Icon(
                            timeSpent >= timeGoal * 60
                                ? Icons.check
                                : habitStarted
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habitName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$timeSpent / ${timeGoal * 60} sec',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: settingsTapped,
              child: Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}
