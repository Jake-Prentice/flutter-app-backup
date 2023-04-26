import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_pi/buttons/change_theme_button.dart';
import 'package:flutter_pi/buttons/icon_button.dart';
import 'package:flutter_pi/navigation_drawer.dart';
import 'package:flutter_pi/buttons/text_box_button.dart';
import 'package:flutter_pi/pages/log_data.dart';
import 'package:flutter_pi/user_data/activity_charts.dart';
import 'package:flutter_pi/user_data/user_data.dart';
import 'package:flutter_pi/pages/progress_graphs.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
  // Stores current user and uses its unique ID to get data from Firestore database
  final UserData userData =
      UserData.createInstance(FirebaseAuth.instance.currentUser!);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  // Steps state elements
  int _dailySteps = 0;
  double _dailyAverageMood = 0;
  double _weeklyAverageMood = 0;
  int _dailyActivityTime = 0;

  // Updates all of the state elements that rely on the user's steps collection
  Future<void> updateStepsElements() async {
    // Updates values
    int dailySteps = await widget.userData.getDailySteps(DateTime.now());

    // Sets new state
    setState(() {
      _dailySteps = dailySteps;
    });
  }

  // Updates all of the state elements that rely on the user's mood collection
  Future<void> updateMoodElements() async {
    // Updates values
    double dailyAverageMood =
        await widget.userData.getDailyAverageMood(DateTime.now());
    double weeklyAverageMood =
        await widget.userData.getWeeklyAverageMood(DateTime.now());

    // Sets new state
    setState(() {
      _dailyAverageMood = dailyAverageMood;
      _weeklyAverageMood = weeklyAverageMood;
    });
  }

  // Updates all of the state elements that rely on the user's activities collection
  Future<void> updateActivityElements() async {
    // Updates values
    int dailyActivityTime =
        await widget.userData.getDailyActivityTime(DateTime.now());

    // Sets new state
    setState(() {
      _dailyActivityTime = dailyActivityTime;
    });
  }

  // Updates user details and refreshes the state
  Future<void> updateUserElements() async {
    await widget.userData.updateUserElements();
    setState(() {});
  }

  // Updates all state elements - used for initial update
  Future<void> updateAllElements() async {
    await widget.userData.updateUserElements();
    await widget.userData.updateStreak();
    await updateStepsElements();
    await updateMoodElements();
    await updateActivityElements();
  }

  // Stores the result of the initial update call and the stream listeners
  Future<void>? _initialUpdate;
  StreamSubscription? userRefListener;
  StreamSubscription? stepsRefListener;
  StreamSubscription? moodRefListener;
  StreamSubscription? activitiesRefListener;

  @override
  void initState() {
    super.initState();
    _initialUpdate = updateAllElements();

    // Sets all user data snapshots to their relevant update functions
    userRefListener = widget.userData.userRef
        .snapshots()
        .listen((event) => updateUserElements());
    stepsRefListener = widget.userData.stepsRef
        .snapshots()
        .listen((event) => updateStepsElements());
    moodRefListener = widget.userData.moodRef
        .snapshots()
        .listen((event) => updateMoodElements());
    activitiesRefListener = widget.userData.activitiesRef
        .snapshots()
        .listen((event) => updateActivityElements());
  }

  // Ensures all of the stream listeners are correctly disposed of
  @override
  void dispose() {
    userRefListener!.cancel();
    stepsRefListener!.cancel();
    moodRefListener!.cancel();
    activitiesRefListener!.cancel();

    super.dispose();
  }

  Widget get dailyMoodInsights => Text(
        _dailyAverageMood == 0
            ? "You haven't logged your mood yet today.\n"
            : ("Your average mood today is ${_dailyAverageMood.toStringAsFixed(1)}/10\n"
                "${_dailyAverageMood >= widget.userData.moodGoal ? "This is above your target mood. Good job!\n" : ""}"
                "Your average mood this week is ${_weeklyAverageMood.toStringAsFixed(1)}/10\n"
                "${_dailyAverageMood >= _weeklyAverageMood ? "Your mood today is above average for this week!\n" : ""}"),
        textAlign: TextAlign.center,
      );

  Widget get dailyActivityInsights => Text(
        _dailyActivityTime == 0
            ? "You haven't logged any activities yet today.\n"
            : ("You've done $_dailyActivityTime minutes of activities today.\n"
                "${_dailyActivityTime >= widget.userData.activitiesGoal ? "This exceeds your goal of ${widget.userData.activitiesGoal} minutes!\n" : "You have not yet reached your goal of ${widget.userData.activitiesGoal} minutes.\n"}"),
        textAlign: TextAlign.center,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Home'),
          actions: [
            ChangeThemeButtonWidget(),
            Padding(
                padding: const EdgeInsets.only(right: 30.0, left: 30),
                child: IconBlob(
                    icon: Icons.notifications, email: user.email.toString())),
          ],
        ),
        drawer: AppNavigationDrawer(),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LogDataPage())),
            backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primary,
            child: const Icon(Icons.add_rounded, color: Colors.white)),
        body: FutureBuilder<void>(
            future: _initialUpdate,
            builder: (context, snapshot) {
              // Show message if an error has occured.
              if (snapshot.hasError) {
                print(snapshot.error.toString());
                return const Center(child: Text('Something went wrong :('));
              }

              // Show loading symbol while doing initial update
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Otherwise, return normal home page ListView
              return ListView(children: [
                Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Text(
                          "Welcome ${widget.userData.username}!",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 40),
                        Center(
                            child: CircularPercentIndicator(
                          radius: 120,
                          percent: _dailySteps < widget.userData.stepsGoal
                              ? _dailySteps / widget.userData.stepsGoal
                              : 1,
                          lineWidth: 45,
                          animation: true,
                          animateFromLastPercent: true,
                          animationDuration: 800,
                          progressColor: Color.lerp(
                              Colors.red,
                              Colors.green,
                              _dailySteps < widget.userData.stepsGoal
                                  ? _dailySteps / widget.userData.stepsGoal
                                  : 1),
                          center: Text(
                            "$_dailySteps/${widget.userData.stepsGoal}\nsteps",
                            textAlign: TextAlign.center,
                          ),
                          rotateLinearGradient: true,
                        )),
                        const SizedBox(height: 50),
                        const Text(
                          "Mood Insights: ",
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        dailyMoodInsights,
                        SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: Row(children: [
                              Expanded(
                                  child: widget.userData.moodRef.graph(
                                      DateTime.now().weekStart,
                                      DateTime.now().weekEnd)),
                              const SizedBox(width: 38)
                            ])),
                        const SizedBox(height: 50),
                        const Text(
                          "Activity Insights: ",
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        dailyActivityInsights,
                        const SizedBox(height: 5),
                        const Text(
                            "Types of activities in the past 30 days:\n"),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              widget.userData.activitiesRef.typeChart(
                                  DateTime.now()
                                      .subtract(const Duration(days: 30)),
                                  70),
                              const SizedBox(width: 40),
                              widget.userData.activitiesRef
                                  .typeChartIndicators(16),
                            ]),
                        const SizedBox(height: 20),
                        const Text(
                            "Intensities of activities in the past 30 days:\n"),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              widget.userData.activitiesRef.intensityChart(
                                  DateTime.now()
                                      .subtract(const Duration(days: 30)),
                                  70),
                              const SizedBox(width: 40),
                              widget.userData.activitiesRef
                                  .intensityChartIndicators(16),
                            ]),
                        const SizedBox(height: 50),
                        const Text(
                          "Change Goals",
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        TextBoxDialogButton(
                          buttonText: "Change Step Goal",
                          textBoxHint: "Enter New Goal...",
                          dialogActions: [
                            DialogAction("Confirm", (t) {
                              int? newGoal = int.tryParse(t.text);
                              if (newGoal != null && newGoal >= 0) {
                                widget.userData.setStepsGoal(newGoal);
                              }
                            }),
                            DialogAction("Cancel", null)
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextBoxDialogButton(
                          buttonText: "Change Mood Goal",
                          textBoxHint: "Enter New Goal...",
                          dialogActions: [
                            DialogAction("Confirm", (t) {
                              int? newGoal = int.tryParse(t.text);
                              if (newGoal != null) {
                                newGoal.clamp(0, 10);
                                widget.userData.setMoodGoal(newGoal);
                              }
                            }),
                            DialogAction("Cancel", null)
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextBoxDialogButton(
                          buttonText: "Change Activities Goal",
                          textBoxHint: "Enter New Goal...",
                          dialogActions: [
                            DialogAction("Confirm", (t) {
                              int? newGoal = int.tryParse(t.text);
                              if (newGoal != null && newGoal >= 0) {
                                widget.userData.setActivitiesGoal(newGoal);
                              }
                            }),
                            DialogAction("Cancel", null)
                          ],
                        ),
                      ],
                    ))
              ]);
            }));
  }
}
