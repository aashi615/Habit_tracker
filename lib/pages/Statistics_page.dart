import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  final List habitList;

  StatisticsPage({required this.habitList});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Statistics'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFF0288d1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: widget.habitList
                  .map((habit) => habit[2] / 60)
                  .reduce((a, b) => a > b ? a : b) + 5,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  tooltipPadding: EdgeInsets.all(12),
                  tooltipMargin: 10,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${widget.habitList[group.x.toInt()][0]}\n',
                      TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${rod.toY.toInt()} min',
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                handleBuiltInTouches: true,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false, // Hide y-axis titles
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          widget.habitList[value.toInt()][0],
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.blue,
                  width: 1,
                ),
              ),
              barGroups: widget.habitList.asMap().entries.map((entry) {
                int index = entry.key;
                var habit = entry.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: habit[2].toDouble() / 60,
                      gradient: LinearGradient(
                        colors: [Colors.purpleAccent, Colors.deepPurple],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 16,
                      borderRadius: BorderRadius.circular(12),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 0,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                );
              }).toList(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.blue.shade100,
                    strokeWidth: 1,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
