import 'package:cloud_firestore/cloud_firestore.dart';

// Class to represent an entry into a table with only a date and single value
class SingleValueEntry {
  SingleValueEntry({
    required this.date, 
    required this.value,
  });
  
  // Creates single value entry from Firestore data
  SingleValueEntry.fromFirestore(Map<String, dynamic> data) : this(
    date: (data['date'] as Timestamp).toDate(), 
    value: data['value']
  );

  // Converts single value entry to a map
  Map<String, dynamic> toFirestore() => {
    'date': Timestamp.fromDate(date),
    'value': value,
  };

  final DateTime date;
  final int value;
}

// Class to represent an entry into the steps table
class StepsEntry extends SingleValueEntry {
  StepsEntry({required super.date, required super.value});

  StepsEntry.fromFirestore(Map<String, dynamic> data) : super.fromFirestore(data);
}

// Class to represent an entry into the mood table
class MoodEntry extends SingleValueEntry {
  MoodEntry({required super.date, required super.value});

  MoodEntry.fromFirestore(Map<String, dynamic> data) : super.fromFirestore(data);
}