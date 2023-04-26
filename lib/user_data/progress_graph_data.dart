import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

extension ProgressDates on DateTime {
  // Returns a DateTime ignoring hours, minutes etc - just in days
  DateTime get inDays => DateTime(year, month, day);
  String get formatted => "$day/$month/$year";

  // Gets the list of days between a DateTime and an end point
  List<DateTime> getRange(DateTime end) {
    List<DateTime> days = [];
    DateTime start = inDays;
    for (int i = 0; i <= end.difference(this).inDays; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }
}

// Class to represent a Data Graph to be plotted on a LineChart
class ProgressGraphData {
  // Date range of the graph, and list of all of the chart's lines
  final List<DateTime> dateRange;
  final List<LineChartBarData> chartLines = [];

  // Gets a date's index in the date range
  int getDateIndex(DateTime date) => date.inDays.difference(dateRange[0]).inDays;

  // Returns the length of the date range
  int get size => dateRange.length;

  // Generates and returns LineChartData to draw the DataGraph to a LineChart
  LineChartData generateChartData(double? maxY, int goal, String tooltipName, bool roundToInt) {
    return LineChartData(
      lineBarsData: chartLines,
      minX: 0,
      minY: 0,
      maxY: maxY,
      maxX: dateRange.length - 1.0,
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: goal.toDouble(),
            color: Colors.grey,
            dashArray: [5, 5] 
          )
        ]
      ),
      lineTouchData: LineTouchData(
        getTouchLineEnd: defaultGetTouchLineEnd,
        handleBuiltInTouches: true,
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          maxContentWidth: 1000,
          getTooltipItems: (spots) => [
            LineTooltipItem(
              "Date: ${dateRange[spots[0].x.toInt()].formatted}\n"
              "$tooltipName: ${roundToInt ? spots[0].y.toInt() : spots[0].y}",
              const TextStyle()
            )
          ]
        )
      )
    );
  }

  // Constructs a DataGraph for data between a start and end date
  ProgressGraphData.fromDates(DateTime start, DateTime end) : 
    dateRange = start.getRange(end);

  // Adds a new chart line to the graph with specified data points and colour
  void addChartLine(List<double> data, Color colour) {
    if (data.length != dateRange.length) return;

    // Generates FlSpots
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      if (dateRange[i].compareTo(DateTime.now().inDays) <= 0) {
        spots.add(FlSpot(i.toDouble(), data[i]));
      }
    }

    // Creates and adds the new line
    chartLines.add(LineChartBarData(
      spots: spots,
      color: colour
    ));
  }
}