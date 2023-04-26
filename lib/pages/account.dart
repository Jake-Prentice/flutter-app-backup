import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi/main.dart';
import 'dart:async';
import 'package:flutter_pi/navigation_drawer.dart';
import 'package:flutter_pi/user_data/achievement.dart';
import 'package:flutter_pi/user_data/user_data.dart';
import 'package:flutter_pi/user_data/user_stats.dart';
import 'package:flutter_pi/buttons/button.dart';
import 'package:flutter_pi/buttons/text_box_button.dart';

class AccountPage extends StatefulWidget {
  AccountPage({super.key});

  final userData = UserData.createInstance(FirebaseAuth.instance.currentUser!);
  final user = FirebaseAuth.instance.currentUser!;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<Achievement> achievements = [];

  Future<void>? _initialUpdate;

  Future<void> updateAccountPage() async {
    await UserData.instance!.updateUserElements();
    await UserData.instance!.updateStreak();
  }


  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final navigator = Navigator.of(context);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              onPressed: () => navigator.pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Delete the user account
                  await widget.user.delete();
                  debugPrint("user deleted successfully");
                  // Navigate back to the login page
                  if (!context.mounted) return;
                  // Navigate back to the login page
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const MainPage()),
                    (Route<dynamic> route) => false,
                  );
                } on FirebaseAuthException catch (e) {
                  // Display an error message if there was a problem deleting the account
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.message ?? "An error occurred")));
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _initialUpdate = updateAccountPage();

    achievements = [
      Achievement(
        name: "Wildfire", 
        iconName: "streak_achievement", 
        levels: [7, 14, 30, 50, 75, 100, 150, 200, 275, 365], 
        getDescription: (goal) => "Reach a $goal day streak", 
        getProgress: (data) => data.stats.longestStreak
      ),
      Achievement(
        name: "Goal Setter", 
        iconName: "goal_achievement", 
        levels: [5, 10, 25, 50, 100], 
        getDescription: (goal) => "Change your goals $goal times", 
        getProgress: (data) => data.stats.goalsSet
      ),
      Achievement(
        name: "Data Logger", 
        iconName: "entry_achievement", 
        levels: [10, 50, 100, 500, 1000], 
        getDescription: (goal) => "Make $goal entries", 
        getProgress: (data) => data.stats.entriesMade
      ),
      Achievement(
        name: "Globe Trotter", 
        iconName: "steps_achievement", 
        levels: [1000, 5000, 10000, 50000, 100000, 250000, 500000, 1000000], 
        getDescription: (goal) => "Log $goal steps", 
        getProgress: (data) => data.stats.stepsLogged
      ),
      Achievement(
        name: "Max Intensity", 
        iconName: "intensity_achievement", 
        levels: [5, 10, 20, 50, 100], 
        getDescription: (goal) => "Complete $goal high intensity activities", 
        getProgress: (data) => data.stats.highActivitiesLogged
      ),
      Achievement(
        name: "Feeling Good", 
        iconName: "mood_achievement", 
        levels: [5, 10, 20, 50, 100], 
        getDescription: (goal) => "Log a mood over 8, $goal times", 
        getProgress: (data) => data.stats.happyMoodsLogged
      ),
    ];
  }

  Widget generateAchievementsList(BuildContext context) => Column(
    children: [
      for (var achievement in achievements) (
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: achievement.build(context)
        )
      )
    ]
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: const Text("Your Account"),
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
    body: FutureBuilder<void>(
      future: _initialUpdate,
      builder: (context, snapshot) {
        // Show message if an error has occured
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong :('));
        }

        // Show loading symbol while doing initial update
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        UserStats stats = UserData.instance!.stats;

        // Otherwise, return normal account page ListView
        return ListView(children: [Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(UserData.instance!.username,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 2),
              Text(widget.user.email!,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                "Joined ${["January", "February", "March", "April", "May", "June", 
                "July", "August", "September", "October", "November", "December"]
                [widget.user.metadata.creationTime!.month - 1]} "
                "${widget.user.metadata.creationTime!.year}"
              ),
              const SizedBox(height: 20),
              const Divider(),
            const SizedBox(height: 4),
            Text(
              'current weight: ${widget.userData.weight.toString()} (kg)',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            TextBoxDialogButton(
              buttonText: "Change",
              textBoxHint: "Enter New Weight",
              width: 100,
              height: 35,
              dialogActions: [
                DialogAction("Confirm", (w) async {
                  double? weight = double.tryParse(w.text);
                  if (weight != null && weight >= 0) {
                    await widget.userData.userRef.update({"weight": weight});
                    setState(() => widget.userData.weight = weight);
                  }
                }),
                DialogAction("Cancel", null)
              ],
            ),
            const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 20),
              const Text("Achievements",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 20),
              generateAchievementsList(context),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              const Text("Stats",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              Text("Current Streak: ${stats.currentStreak}"),
              Text("Longest Streak: ${stats.longestStreak}"),
              Text("Goals Set: ${stats.goalsSet}"),
              Text("Data Entries Made: ${stats.entriesMade}"),
              Text("Steps Logged: ${stats.stepsLogged}"),
              Text("Moods Logged: ${stats.moodLogged}"),
              Text("Happy Moods Logged: ${stats.happyMoodsLogged}"),
              Text("Activities Logged: ${stats.activitiesLogged}"),
              Text("Low Intensity Activities Logged: ${stats.lowActivitiesLogged}"),
              Text("Medium Intensity Activities Logged: ${stats.mediumActivitiesLogged}"),
              Text("High Intensity Activities Logged: ${stats.highActivitiesLogged}"),
              Text("Activity Minutes Logged: ${stats.activityMinutesLogged}"),
                   const SizedBox(height: 20),
            generateAchievementsList(context),
            const Divider(),
            const Text(
              "Danger Zone",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Button(
                  buttonText: "delete account",
                  width: 200,
                  onPressed: _showDeleteConfirmationDialog),
            )
            ]
          ),
        )]);
      },
    )
  );
}