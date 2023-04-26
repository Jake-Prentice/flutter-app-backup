import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi/main.dart';
import 'package:flutter_pi/navigation_drawer.dart';
import 'package:flutter_pi/user_data/activity_entry.dart';
import 'package:flutter_pi/user_data/progress_graph_data.dart';
import 'package:flutter_pi/user_data/single_value_entry.dart';
import 'package:flutter_pi/user_data/user_data.dart';

// Allows the steps collection to be graphed
extension StepsGraphing on CollectionReference<StepsEntry> {
  // Returns a line chart for the collection, showing entries between
  // the specified start and end date
  Widget graph(DateTime start, DateTime end) { 
    return StreamBuilder<QuerySnapshot<StepsEntry>>(
      stream: UserData.filterBetween(this, 
        start, end.add(const Duration(days: 1))
      ).snapshots(),
      builder: (context, snapshot) {
        // Shows loading symbol while data is not available
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Creates data graph for the date range
        var dataGraph = ProgressGraphData.fromDates(start, end);
    
        // Uses current snapshot to find total step values for each day in range
        List<double> totals = [];
        for (int i = 0; i < dataGraph.size; i++) {
          totals.add(0);
        }
        for (var doc in snapshot.data!.docs) {
          StepsEntry entry = doc.data();
          totals[dataGraph.getDateIndex(entry.date)] += entry.value;
        }

        // Adds a line for the totalled data, and then generates the chart
        dataGraph.addChartLine(totals, Colors.green[400]!);
        return LineChart(dataGraph.generateChartData(
          null, UserData.instance!.stepsGoal, "Steps", true
        ));
      }
    );
  }
}

// Allows the mood collection to be graphed
extension MoodGraphing on CollectionReference<MoodEntry> {
  // Returns a line chart for the collection, showing entries between
  // the specified start and end date
  Widget graph(DateTime start, DateTime end) { 
    return StreamBuilder<QuerySnapshot<MoodEntry>>(
      stream: UserData.filterBetween(this, 
        start, end.add(const Duration(days: 1))
      ).snapshots(),
      builder: (context, snapshot) {
        // Shows loading symbol while data is not available
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Creates data graph for the date range
        var dataGraph = ProgressGraphData.fromDates(start, end);
    
        // Uses current snapshot to find average mood values for each day in range
        List<double> totals = [];
        List<int> counts = [];
        for (int i = 0; i < dataGraph.size; i++) {
          totals.add(0);
          counts.add(0);
        }
        for (var doc in snapshot.data!.docs) {
          MoodEntry entry = doc.data();
          totals[dataGraph.getDateIndex(entry.date)] += entry.value;
          counts[dataGraph.getDateIndex(entry.date)]++;
        }
        for (int i = 0; i < dataGraph.size; i++) {
          if (counts[i] > 0) { 
            totals[i] = ((totals[i] / counts[i]) * 10).round() / 10;
          }
        }

        // Adds a line for the averaged data, and then generates the chart
        dataGraph.addChartLine(totals, Colors.red[400]!);
        return LineChart(dataGraph.generateChartData(
          10, UserData.instance!.moodGoal, "Mood", false
        ));
      }
    );
  }
}

// Allows the activities collection to be graphed
extension ActivityGraphing on CollectionReference<ActivityEntry> {
  // Returns a line chart for the collection, showing entries between
  // the specified start and end date
  Widget graph(DateTime start, DateTime end) { 
    return StreamBuilder<QuerySnapshot<ActivityEntry>>(
      stream: UserData.filterBetween(this, 
        start, end.add(const Duration(days: 1))
      ).snapshots(),
      builder: (context, snapshot) {
        // Shows loading symbol while data is not available
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Creates data graph for the date range
        var dataGraph = ProgressGraphData.fromDates(start, end);
    
        // Uses current snapshot to find total step values for each day in range
        List<double> totals = [];
        for (int i = 0; i < dataGraph.size; i++) {
          totals.add(0);
        }
        for (var doc in snapshot.data!.docs) {
          ActivityEntry entry = doc.data();
          totals[dataGraph.getDateIndex(entry.date)] += entry.duration;
        }

        // Adds a line for the totalled data, and then generates the chart
        dataGraph.addChartLine(totals, Colors.blue[400]!);
        return LineChart(dataGraph.generateChartData(
          null, UserData.instance!.activitiesGoal, "Duration", true
        ));
      }
    );
  }
}

// Allows the activities collection to be graphed
extension CaloriesBurntGraphing on CollectionReference<ActivityEntry> {
  // Returns a line chart for the collection, showing entries between
  // the specified start and end date
  Widget graphCaloriesBurnt(DateTime start, DateTime end) { 
    return StreamBuilder<QuerySnapshot<ActivityEntry>>(
      stream: UserData.filterBetween(this, 
        start, end.add(const Duration(days: 1))
      ).snapshots(),
      builder: (context, snapshot) {
        // Shows loading symbol while data is not available
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Creates data graph for the date range
        var dataGraph = ProgressGraphData.fromDates(start, end);
    
        // Uses current snapshot to find total step values for each day in range
        List<double> totals = [];
        for (int i = 0; i < dataGraph.size; i++) {
          totals.add(0);
        }
        for (var doc in snapshot.data!.docs) {
          ActivityEntry entry = doc.data();
          totals[dataGraph.getDateIndex(entry.date)] += entry.caloriesBurnt;
        }

        // Adds a line for the totalled data, and then generates the chart
        dataGraph.addChartLine(totals, Colors.red[400]!);
        return LineChart(dataGraph.generateChartData(
          null, UserData.instance!.activitiesGoal, "Calories burnt", true
        ));
      }
    );
  }
}

// Adds getters for a DateTime's week start, week end, and formatted string
extension WeekDateTimes on DateTime {
  DateTime get weekStart => DateTime(year, month, day - weekday + 1);
  DateTime get weekEnd => DateTime(year, month, day - weekday + 7);
}

// Page to show totalled/averaged data for each database on a graph
class ProgressGraphsPage extends StatefulWidget {
  const ProgressGraphsPage({super.key});

  @override
  State<ProgressGraphsPage> createState() => _ProgressGraphsPageState();
}

class _ProgressGraphsPageState extends State<ProgressGraphsPage> {
  // The current start/end of the date range to be shown
  DateTime _start = DateTime.now().weekStart;
  DateTime _end = DateTime.now().weekEnd;

  // Opens a date picker to select the start date of the range
  Future<void> _selectStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context, 
      initialDate: _start, 
      firstDate: DateTime.now().weekStart.subtract(const Duration(days: 55)), 
      lastDate: _end
    );
    if (pickedDate != null && pickedDate != _start) {
      setState(() =>_start = pickedDate);
    }
  }

  // Opens a date picker to select the end date of the range
  Future<void> _selectEndDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context, 
      initialDate: _end, 
      firstDate: _start, 
      lastDate: DateTime.now().weekEnd
    );
    if (pickedDate != null && pickedDate != _end) {
      setState(() => _end = pickedDate);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Progress Graphs"),
      ),
      drawer: AppNavigationDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: 
            (context) => const MainPage()
          )
        ),
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primary,
        child: const Icon(Icons.home_rounded)
      ),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Text("Current data being shown: ${_start.formatted} - ${_end.formatted}"),
        const SizedBox(height: 16),
        Row(children: [
          const SizedBox(width: 8),
          const Text("Change Range: "),
          const SizedBox(width: 15),
          Expanded(child: ElevatedButton(
            onPressed: () => _selectStartDate(context), 
            child: const Text("Choose Start Date", textAlign: TextAlign.center,)
          )),
          const SizedBox(width: 15),
          Expanded(child: ElevatedButton(
            onPressed: () => _selectEndDate(context), 
            child: const Text("Choose End Date", textAlign: TextAlign.center,)
          )),
          const SizedBox(width: 8),
        ]),
        const SizedBox(height: 20),
        Row(children: const [
          Expanded(child: Padding(padding: EdgeInsets.all(8),
            child: Center(child: Text("Total Steps"))
          ))
        ]),
        Expanded(child: Row(children: [
          Expanded(child: UserData.instance!.stepsRef.graph(_start, _end)),
          const SizedBox(width: 38)
        ])),
        const SizedBox(height: 22),
        Row(children: const [
          Expanded(child: Padding(padding: EdgeInsets.all(8),
            child: Center(child: Text("Average Mood"))
          ))
        ]),
        Expanded(child: Row(children: [
          Expanded(child: UserData.instance!.moodRef.graph(_start, _end)),
          const SizedBox(width: 38)
        ])),
        const SizedBox(height: 22),
        Row(children: const [
          Expanded(child: Padding(padding: EdgeInsets.all(8),
            child: Center(child: Text("Total Activity Duration"))
          ))
        ]),
        Expanded(child: Row(children: [
          Expanded(child: UserData.instance!.activitiesRef.graph(_start, _end)),
          const SizedBox(width: 38)
        ])),
        const SizedBox(height: 20),
          Row(children: const [
          Expanded(child: Padding(padding: EdgeInsets.all(8),
            child: Center(child: Text("Total Calories Burnt"))
          ))
        ]),
        Expanded(child: Row(children: [
          Expanded(child: UserData.instance!.activitiesRef.graphCaloriesBurnt(_start, _end)),
          const SizedBox(width: 38)
        ])),
        const SizedBox(height: 20)
      ])
    ));
  }
}