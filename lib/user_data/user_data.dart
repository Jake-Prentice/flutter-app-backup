import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi/user_data/activity_entry.dart';
import 'package:flutter_pi/user_data/progress_graph_data.dart';
import 'package:flutter_pi/user_data/single_value_entry.dart';
import 'package:flutter_pi/user_data/user_stats.dart';

// Enum for storing each type of database
enum DatabaseTypes {
  steps,
  mood,
  activities
}

class UserData {
  // Static reference to the Firestore database
  static FirebaseFirestore db = FirebaseFirestore.instance;

  // Static reference to the most recently created UserData instance
  static UserData? instance;

  // References to user and user docuement
  final User user;
  DocumentReference get userRef => db.doc("users/${user.uid}");

  // Gets a new reference to the steps collection
  CollectionReference<StepsEntry> get stepsRef {
    return userRef.collection("steps").withConverter<StepsEntry>(
      fromFirestore: (snapshot, _) => StepsEntry.fromFirestore(snapshot.data()!),
      toFirestore: (entry, _) => entry.toFirestore(),
    );
  }

  // Gets a new reference to the mood collection
  CollectionReference<MoodEntry> get moodRef {
    return userRef.collection("mood").withConverter<MoodEntry>(
      fromFirestore: (snapshot, _) => MoodEntry.fromFirestore(snapshot.data()!),
      toFirestore: (entry, _) => entry.toFirestore(),
    );
  }

  // Gets a new reference to the activities collection
  CollectionReference<ActivityEntry> get activitiesRef {
    return userRef.collection("activities").withConverter<ActivityEntry>(
      fromFirestore: (snapshot, _) => ActivityEntry.fromFirestore(snapshot.data()!),
      toFirestore: (entry, _) => entry.toFirestore(),
    );
  }

  // Stores most recently fetched user information
  String username = "User";
  int stepsGoal = 4000;
  int moodGoal = 6;
  int activitiesGoal = 30;
  double? weight;
  // Stores other user stats
  UserStats? _stats;
  UserStats get stats {
    if (_stats != null) {
      return _stats!;
    } else {
      return UserStats(userRef);
    }
  } 

  // Creates user data instance for a specified User 
  UserData._(this.user);
  static UserData createInstance(User user) {
    instance ??= UserData._(user);
    return instance!;
  }

  static void destroyInstance() {
    instance = null;
  }

  // Prints the contents of the specified subcollection to the debug terminal
  Future<void> debugPrintData(String collection) async {
    debugPrint("Printing data:");
    await userRef.collection(collection).get().then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        debugPrint('${docSnapshot.id} => ${docSnapshot.data()}');
      }
    }).catchError((e) { debugPrint("Error printing data: $e"); });
  }

  // Updates stored user information
  Future<void> updateUserElements() async {
    final userDoc = await userRef.get();

    // Updates values
    username = userDoc.get("name");
    stepsGoal = userDoc.get("stepsGoal");
    moodGoal = userDoc.get("moodGoal");
    activitiesGoal = userDoc.get("activitiesGoal");
      weight = userDoc.get("weight");

    _stats = UserStats.fromMap(userRef, userDoc.get("stats") as Map);
    UserStats.statsLoaded = true;
  }

  // Updates user streak based on last login time
  Future<void> updateStreak() async {
    DateTime last = stats.lastLogin.toDate();
    int diff = DateTime.now().inDays.difference(last.inDays).inDays;
    
    if (diff == 0) return;

    stats.lastLogin = Timestamp.now();
    stats.currentStreak = diff == 1 ? stats.currentStreak + 1 : 1;
    if (stats.currentStreak > stats.longestStreak) {
      stats.longestStreak = stats.currentStreak;
    }
    await stats.update();
  }

  // Sets the current user's username
  Future<void> setUsername(String name) async {
    await userRef.update({"name": name});
    username = name;
  }

  // Sets the current user's step goal
  Future<void> setStepsGoal(int goal) async {
    await userRef.update({"stepsGoal": goal});
    stats.goalsSet++;
    await stats.update();
    stepsGoal = goal;
  }

  // Sets the current user's mood goal
  Future<void> setMoodGoal(int goal) async {
    await userRef.update({"moodGoal": goal});
    stats.goalsSet++;
    await stats.update();
    moodGoal = goal;
  }

  // Sets the current user's activities goal
  Future<void> setActivitiesGoal(int goal) async {
    await userRef.update({"activitiesGoal": goal});
    stats.goalsSet++;
    await stats.update();
    activitiesGoal = goal;
  }

  // Adds new steps entry at the current time
  Future<void> addSteps(int steps) async { 
    await stepsRef.add(
      StepsEntry(date: DateTime.now(), value: steps)
    );
    stats.stepsLogged += steps;
    stats.entriesMade++;
    await stats.update();
  }

  // Adds new mood entry at the current time
  Future<void> addMood(int mood) async {
    await moodRef.add(
      MoodEntry(date: DateTime.now(), value: mood)
    );
    if (mood > 7) {
      stats.happyMoodsLogged++;
    }
    stats.moodLogged++;
    stats.entriesMade++;
    await stats.update();
  }

  // Adds new activity entry at the current time
  Future<void> addActivity(
    ActivityType type, ActivityIntensity intensity, int minutes, int caloriesBurnt
  ) async { 
    await activitiesRef.add(ActivityEntry(
      date: DateTime.now(), 
      type: type,
      intensity: intensity,
      duration: minutes,
       caloriesBurnt: caloriesBurnt
    ));
    switch (intensity) {
      case ActivityIntensity.low:
        stats.lowActivitiesLogged++;
        break;
      case ActivityIntensity.medium:
        stats.mediumActivitiesLogged++;
        break;
      case ActivityIntensity.high:
        stats.highActivitiesLogged++;
        break;
    }
    stats.activitiesLogged++;
    stats.entriesMade++;
    stats.activityMinutesLogged += minutes;
    await stats.update();
  }

  // Returns a query containing all entries before a specified date
  static Query<T> filterBefore<T>(Query<T> query, DateTime date) =>
    query.where("date", isLessThan: Timestamp.fromDate(date));

  // Returns a query containing all entries after a specified date
  static Query<T> filterAfter<T>(Query<T> query, DateTime date) =>
    query.where("date", isGreaterThan: Timestamp.fromDate(date));

  // Returns a query containing all entries between two dates
  static Query<T> filterBetween<T>(Query<T> query, DateTime start, DateTime end) =>
    filterBefore(filterAfter(query, start), end);

  // Returns a query containing all entries with a lower value than what was specified 
  static Query<SingleValueEntry> filterLowerValue(Query<SingleValueEntry> query, int value) =>
    query.where("value", isLessThan: value);

  // Returns a query containing all entries with a higher value than what was specified 
  static Query<SingleValueEntry> filterHigherValue(Query<SingleValueEntry> query, int value) =>
    query.where("value", isGreaterThan: value);
  
  // Gets the total amount of steps from a specified date's day
  Future<int> getDailySteps(DateTime date) async {
    // Queries database for entries on the date's day
    var querySnapshot = await filterBetween(stepsRef, 
      DateTime(date.year, date.month, date.day), 
      DateTime(date.year, date.month, date.day + 1)
    ).get();

    // Calculates total number of steps from returned documents
    int total = 0;
    for (var docSnapshot in querySnapshot.docs) {
      total += docSnapshot.data().value;
    }
    return total;
  }

  // Gets the total amount of steps from a specified date's week
  Future<int> getWeeklySteps(DateTime date) async {
    // Queries database for entries in the date's week
    var querySnapshot = await filterBetween(stepsRef, 
      DateTime(date.year, date.month, date.day - date.weekday + 1), 
      DateTime(date.year, date.month, date.day - date.weekday + 8)
    ).get();

    // Calculates total number of steps from returned documents
    int total = 0;
    for (var docSnapshot in querySnapshot.docs) {
      total += docSnapshot.data().value;
    }
    return total;
  }

  // Gets the average mood from a specified date's day
  Future<double> getDailyAverageMood(DateTime date) async {
    // Queries database for entries on the date's day
    var querySnapshot = await filterBetween(moodRef, 
      DateTime(date.year, date.month, date.day), 
      DateTime(date.year, date.month, date.day + 1)
    ).get();

    // Calculates average mood from returned documents
    int total = 0;
    for (var docSnapshot in querySnapshot.docs) {
      total += docSnapshot.data().value;
    }
    return querySnapshot.size > 0 ? total / querySnapshot.size : 0;
  }

  // Gets hte average mood from a specified date's week
  Future<double> getWeeklyAverageMood(DateTime date) async {
    // Queries database for entries in the date's week
    var querySnapshot = await filterBetween(moodRef, 
      DateTime(date.year, date.month, date.day - date.weekday + 1), 
      DateTime(date.year, date.month, date.day - date.weekday + 8)
    ).get();

    // Calculates average mood from returned documents
    int total = 0;
    for (var docSnapshot in querySnapshot.docs) {
      total += docSnapshot.data().value;
    }
    return querySnapshot.size > 0 ? total / querySnapshot.size : 0;
  }

  // Gets the total amount of steps from a specified date's day
  Future<int> getDailyActivityTime(DateTime date) async {
    // Queries database for entries on the date's day
    var querySnapshot = await filterBetween(activitiesRef, 
      DateTime(date.year, date.month, date.day), 
      DateTime(date.year, date.month, date.day + 1)
    ).get();

    // Calculates total number of steps from returned documents
    int total = 0;
    for (var docSnapshot in querySnapshot.docs) {
      total += docSnapshot.data().duration;
    }
    return total;
  }

  // Gets the total amount of steps from a specified date's week
  Future<int> getWeeklyActivityTime(DateTime date) async {
    // Queries database for entries in the date's week
    var querySnapshot = await filterBetween(activitiesRef, 
      DateTime(date.year, date.month, date.day - date.weekday + 1), 
      DateTime(date.year, date.month, date.day - date.weekday + 8)
    ).get();

    // Calculates total number of steps from returned documents
    int total = 0;
    for (var docSnapshot in querySnapshot.docs) {
      total += docSnapshot.data().duration;
    }
    return total;
  }

}