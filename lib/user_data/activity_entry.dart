import 'package:cloud_firestore/cloud_firestore.dart';

// Specific types of activity that can be tracked
enum ActivityType {
  walking,
  running,
  sport,
  aerobic,
  other
}

// The intensity of a specific activity
enum ActivityIntensity {
  low,
  medium,
  high
}

// Class to represent an entry into the activities collection
class ActivityEntry {
  ActivityEntry({
    required this.date, 
    required this.type,
    required this.duration,
    required this.intensity,
    required this.caloriesBurnt
  });
  
  // Creates activity entry from Firestore data
  ActivityEntry.fromFirestore(Map<String, dynamic> data) : this(
    date: (data['date'] as Timestamp).toDate(), 
    type: ActivityType.values[data['type']],
    duration: data['duration'],
    intensity: ActivityIntensity.values[data['intensity']],
          caloriesBurnt: data['caloriesBurnt']
  );

  // Converts activity entry to a map
  Map<String, dynamic> toFirestore() => {
    'date': Timestamp.fromDate(date),
    'type': type.index,
    'duration': duration,
    'intensity': intensity.index,
         'caloriesBurnt': caloriesBurnt
  };

  final DateTime date;
  final ActivityType type;
  final int duration;
  final ActivityIntensity intensity;
  final int caloriesBurnt;
}