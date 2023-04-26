
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_pi/user_data/single_value_entry.dart';

class OldWeeklyReportPage extends StatefulWidget {
  const OldWeeklyReportPage({super.key});

  @override
  State<OldWeeklyReportPage> createState() => _OldWeeklyReportPageState();
}

class _OldWeeklyReportPageState extends State<OldWeeklyReportPage> {
  final touchedStepsText = TextStyle(fontSize: 18, color: Colors.green[300]);
  final touchedMoodText = TextStyle(fontSize: 18, color: Colors.red[300]);
  final touchedDayText = const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold);
  final days = <String>["M","Tu","W","Th","F","Sa","Su"];
  var i = 0;
  var j = 0;
  var factor = 0;

  List<StepsEntry> testStepsData = [
    StepsEntry(date: DateTime.now(), value: 200),
    StepsEntry(date: DateTime.now(), value: 300),
    StepsEntry(date: DateTime.now(), value: 100),
    StepsEntry(date: DateTime.now(), value: 500),
    StepsEntry(date: DateTime.now(), value: 400),
    StepsEntry(date: DateTime.now(), value: 400),
    StepsEntry(date: DateTime.now(), value: 600)
  ];

  List<MoodEntry> testMoodData = [
    MoodEntry(date: DateTime.now(), value: 6),
    MoodEntry(date: DateTime.now(), value: 7),
    MoodEntry(date: DateTime.now(), value: 1),
    MoodEntry(date: DateTime.now(), value: 5),
    MoodEntry(date: DateTime.now(), value: 6),
    MoodEntry(date: DateTime.now(), value: 5),
    MoodEntry(date: DateTime.now(), value: 7),
  ];

  List<FlSpot> resizeStepAxis(List<StepsEntry> entries) {
    List <int> arr = [];
    int max = 0;
    for (StepsEntry entry in entries) {
      arr.add(entry.value);
      if (entry.value > max) {
        max = entry.value;
      }
    }
    factor = (max/10).floor();
    return List<FlSpot>.generate(arr.length, (index) => FlSpot(index as double ,arr[index]/factor));
  }

  Widget scaleSteps(double value, TitleMeta title) {
    return Text("${value*factor}", style: touchedStepsText);
  }

  List<LineTooltipItem> getTouchedSpot(List<LineBarSpot> spot) {
    List<LineTooltipItem> info = [];
    for (LineBarSpot s in spot) {
      if (s.barIndex == 0) {
        info.insert(0,LineTooltipItem("Steps: ${s.y*factor}", touchedStepsText));
      } else {
        info.add(LineTooltipItem("Mood: ${s.y}", touchedMoodText));
      }
    }
    return info;
  }
  String getDay(int index) {return days[index].toUpperCase();}
  Widget getDayText(double index, TitleMeta title) {
    return Text("\n${getDay(index as int)}", style: touchedDayText);
  }

  Widget getMoodText(double val, TitleMeta title) {
    return Text("   ${val as int}", style:touchedMoodText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Weekly Report")
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 100,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: LineChart(
                LineChartData(

                    lineBarsData: [
                      LineChartBarData(
                        color: Colors.green[300],
                        spots: [
                          ...resizeStepAxis(testStepsData)
                        ],
                      ),
                      LineChartBarData(
                        color: Colors.red[300],
                        spots: [
                          for (MoodEntry entry in testMoodData)
                            FlSpot((j++) as double, entry.value as double)
                        ],
                      ),
                    ],
                   maxY: 10,
                   minY: 0,
                   gridData: FlGridData(show: false),
                   titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(axisNameSize: 30, axisNameWidget: Text("Day of week", style: touchedDayText),sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize:50, getTitlesWidget: getDayText)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(axisNameSize: 30, axisNameWidget: Text("Mood",style: touchedMoodText), sideTitles: SideTitles(showTitles: true, reservedSize: 50, interval: 1, getTitlesWidget: getMoodText)),
                    leftTitles: AxisTitles(axisNameSize: 30, axisNameWidget: Text("Steps", style: touchedStepsText,), sideTitles: SideTitles(showTitles: true, reservedSize: 100, interval: 1, getTitlesWidget: scaleSteps)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    getTouchLineStart: defaultGetTouchLineEnd,
                    handleBuiltInTouches: true,
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      maxContentWidth: 1000,
                      getTooltipItems: getTouchedSpot,
                    )
                  )
                  // read about it in the LineChartData section
                ),

              ),
            ),
          ),
        ],
      ),
    );
  }
}