import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi/user_data/activity_entry.dart';
import 'package:flutter_pi/user_data/user_data.dart';

// Allows enums to be formatted with a starting capital letter for the table
extension on Enum {
  String get capitalised {
    return name[0].toUpperCase() + name.substring(1);
  }
}

final typeColours = {
  ActivityType.walking: Colors.red.shade600,
  ActivityType.running: Colors.orange.shade300,
  ActivityType.sport: Colors.green.shade400,
  ActivityType.aerobic: Colors.blue.shade400,
  ActivityType.other: Colors.purple.shade300,
};

List<PieChartSectionData> getTypeSections(double radius, Map<ActivityType, int> typesMap) {
  return typesMap.map<ActivityType, PieChartSectionData>((key, value) => 
    MapEntry(key, PieChartSectionData(
      value: value.toDouble(),
      showTitle: false,
      color: typeColours[key]!,
      radius: radius
    ))
  ).values.toList();
}

final intensityColours = {
  ActivityIntensity.low: Colors.red.shade600,
  ActivityIntensity.medium: Colors.orange.shade300,
  ActivityIntensity.high: Colors.green.shade400,
};

List<PieChartSectionData> getIntensitySections(double radius, Map<ActivityIntensity, int> intensitiesMap) {
  return intensitiesMap.map<ActivityIntensity, PieChartSectionData>((key, value) => 
    MapEntry(key, PieChartSectionData(
      value: value.toDouble(),
      showTitle: false,
      color: intensityColours[key]!,
      radius: radius
    ))
  ).values.toList();
}

// Allows pie charts to be created for activity entry collections
extension ActivityCharts on CollectionReference<ActivityEntry> {
  // Returns a chart showing the types of activities
  Widget typeChart(DateTime start, double radius) {
    return StreamBuilder<QuerySnapshot<ActivityEntry>>(
      stream: UserData.filterBetween(this, 
        start, DateTime.now()
      ).snapshots(),
      builder: (context, snapshot) {
        // Shows loading symbol while data is not available
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final typesMap = {
          ActivityType.walking: 0,
          ActivityType.running: 0,
          ActivityType.sport: 0,
          ActivityType.aerobic: 0,
          ActivityType.other: 0,
        };

        for (var doc in snapshot.data!.docs) {
          ActivityEntry entry = doc.data();
          typesMap[entry.type] = typesMap[entry.type]! + 1;
        }

        return SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: PieChart(
            PieChartData(
              sections: getTypeSections(radius / 2, typesMap),
              sectionsSpace: 0, 
              centerSpaceRadius: radius / 2,
              borderData: FlBorderData(show: false),
              startDegreeOffset: -90
            )
          )
        );
      },
    );
  }

  // Returns indicators for the type chart
  Widget typeChartIndicators(double size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: typeColours.map<ActivityType, Widget>((key, value) => 
        MapEntry(key, Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: size, 
                height: size,
                decoration: BoxDecoration(shape: BoxShape.circle, color: value),
              ),
              const SizedBox(width: 8),
              Text(
                key.capitalised,
                style: TextStyle(
                  fontSize: size,
                ),
              )
            ],
          )
        ))
      ).values.toList(),
    );
  }

  // Returns a chart showing the intensities of activities
  Widget intensityChart(DateTime start, double radius) {
    return StreamBuilder<QuerySnapshot<ActivityEntry>>(
      stream: UserData.filterBetween(this, 
        start, DateTime.now()
      ).snapshots(),
      builder: (context, snapshot) {
        // Shows loading symbol while data is not available
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final intensitiesMap = {
          ActivityIntensity.low: 0,
          ActivityIntensity.medium: 0,
          ActivityIntensity.high: 0,
        };

        for (var doc in snapshot.data!.docs) {
          ActivityEntry entry = doc.data();
          intensitiesMap[entry.intensity] = intensitiesMap[entry.intensity]! + 1;
        }

        return SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: PieChart(
            PieChartData(
              sections: getIntensitySections(radius / 2, intensitiesMap),
              sectionsSpace: 0, 
              centerSpaceRadius: radius / 2,
              borderData: FlBorderData(show: false),
              startDegreeOffset: -90
            )
          )
        );
      },
    );
  }

  // Returns indicators for the intensity chart
  Widget intensityChartIndicators(double size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: intensityColours.map<ActivityIntensity, Widget>((key, value) => 
        MapEntry(key, Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: size, 
                height: size,
                decoration: BoxDecoration(shape: BoxShape.circle, color: value),
              ),
              const SizedBox(width: 8),
              Text(
                key.capitalised,
                style: TextStyle(
                  fontSize: size,
                ),
              )
            ],
          )
        ))
      ).values.toList(),
    );
  }
}