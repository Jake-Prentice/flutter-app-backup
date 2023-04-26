import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  static bool statsLoaded = false;

  final DocumentReference userRef;

  int longestStreak = 0;
  int currentStreak = 1;
  Timestamp lastLogin = Timestamp.now();
  int goalsSet = 0;
  int entriesMade = 0;
  int stepsLogged = 0;
  int moodLogged = 0;
  int happyMoodsLogged = 0;
  int activitiesLogged = 0;
  int lowActivitiesLogged = 0;
  int mediumActivitiesLogged = 0;
  int highActivitiesLogged = 0;
  int activityMinutesLogged = 0;

  UserStats(this.userRef);

  UserStats.fromMap(this.userRef, Map map) {
    longestStreak = map['longestStreak'];
    currentStreak = map['currentStreak'];
    lastLogin = map['lastLogin'];
    goalsSet = map['goalsSet'];
    entriesMade = map['entriesMade'];
    stepsLogged = map['stepsLogged'];
    moodLogged = map['moodLogged'];
    happyMoodsLogged = map['happyMoodsLogged'];
    activitiesLogged = map['activitiesLogged'];
    lowActivitiesLogged = map['lowActivitiesLogged'];
    mediumActivitiesLogged = map['mediumActivitiesLogged'];
    highActivitiesLogged = map['highActivitiesLogged'];
    activityMinutesLogged = map['activityMinutesLogged'];
  }

  static Map get defaultMap => {
    'longestStreak': 0,
    'currentStreak': 1,
    'lastLogin': Timestamp.now(),
    'goalsSet': 0,
    'entriesMade': 0,
    'stepsLogged': 0,
    'moodLogged': 0,
    'happyMoodsLogged': 0,
    'activitiesLogged': 0,
    'lowActivitiesLogged': 0,
    'mediumActivitiesLogged': 0,
    'highActivitiesLogged': 0,
    'activityMinutesLogged': 0,
  };

  Map get currentMap => {
    'longestStreak': longestStreak,
    'currentStreak': currentStreak,
    'lastLogin': lastLogin,
    'goalsSet': goalsSet,
    'entriesMade': entriesMade,
    'stepsLogged': stepsLogged,
    'moodLogged': moodLogged,
    'happyMoodsLogged': happyMoodsLogged,
    'activitiesLogged': activitiesLogged,
    'lowActivitiesLogged': lowActivitiesLogged,
    'mediumActivitiesLogged': mediumActivitiesLogged,
    'highActivitiesLogged': highActivitiesLogged,
    'activityMinutesLogged': activityMinutesLogged,
  };

  Future<void> update() async {
    if (statsLoaded) await userRef.update({"stats": currentMap});
  }
}