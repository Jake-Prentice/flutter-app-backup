import 'package:flutter/material.dart';
import 'package:flutter_pi/buttons/button.dart';
import 'package:flutter_pi/main.dart';
import 'package:flutter_pi/navigation_drawer.dart';
import 'package:flutter_pi/user_data/activity_entry.dart';
import 'package:flutter_pi/user_data/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Allows enums to be formatted with a starting capital letter for the table
extension on Enum {
  String get capitalised {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class LogDataPage extends StatefulWidget {
  LogDataPage({super.key});

  final formKey = GlobalKey<FormState>();
    final userData = UserData.createInstance(FirebaseAuth.instance.currentUser!);

  @override
  State<LogDataPage> createState() => _LogDataPageState();
}

class _LogDataPageState extends State<LogDataPage> {
    Map<ActivityType, Map<ActivityIntensity, double>> toMet = {
    ActivityType.walking: {ActivityIntensity.low: 2, ActivityIntensity.medium: 3.5, ActivityIntensity.high: 5},
    ActivityType.sport: {ActivityIntensity.low: 9, ActivityIntensity.medium: 10, ActivityIntensity.high: 13},
    ActivityType.running: {ActivityIntensity.low: 10, ActivityIntensity.medium: 11.5, ActivityIntensity.high: 13},
    ActivityType.aerobic: {ActivityIntensity.low: 5, ActivityIntensity.medium: 6, ActivityIntensity.high: 8}
  };

  bool _validateInputs = false;
  String _formSuccessMessage = "";
  DatabaseTypes _currentDatabase = DatabaseTypes.steps;
    bool isCaloriesInputEnabled = false;
  int calsBurnt = -1;

  ActivityType _activityType = ActivityType.walking;
  ActivityIntensity _activityIntensity = ActivityIntensity.medium;

  // Text Controllers for form input
  final _inputController = TextEditingController();
  final _calorieInputController = TextEditingController();

    int calculateCaloriesBurnt(double weight, int duration) {
    double met = toMet[_activityType]![_activityIntensity]!;
    return (duration * (met * 3.5 * weight) / 200).round();
  }

  void reCalculateCalsBurnt() {
    if (isCaloriesInputEnabled && _activityType != ActivityType.other) {
      int newCalsBurnt = calculateCaloriesBurnt(
          widget.userData.weight!, int.tryParse(_inputController.text)!);
      setState(() {
        calsBurnt = newCalsBurnt;
      });
    }
  }


  Widget get _stepsInput => Padding(
    padding: const EdgeInsets.all(40),
    child: Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.number,
            controller: _inputController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: "Steps"),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => _validateInputs && value != null &&
              (int.tryParse(value.trim()) == null || int.parse(value.trim()) < 0)
              ? "Please enter a positive integer value." : null,
          ),
          const SizedBox(height: 20),
          Button(
            buttonText: "Log Steps",
            onPressed: logSteps,
            width: double.infinity,
          ),
          const SizedBox(height: 6),
          Text(
            _formSuccessMessage, 
            style: TextStyle(
              fontSize: _formSuccessMessage.isEmpty ? 0 : 12,
              color: const Color.fromARGB(255, 0, 127, 0),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
  );

  Widget get _moodInput => Padding(
    padding: const EdgeInsets.all(40),
    child: Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.number,
            controller: _inputController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: "Mood"),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => _validateInputs && value != null &&
              (int.tryParse(value.trim()) == null ||
              int.parse(value.trim()) <= 0 || int.parse(value.trim()) > 10)
              ? "Please enter an integer between 1 and 10." : null,
          ),
          const SizedBox(height: 20),
          Button(
            buttonText: "Log Mood",
            onPressed: logMood,
            width: double.infinity,
          ),
          const SizedBox(height: 6),
          Text(
            _formSuccessMessage, 
            style: TextStyle(
              fontSize: _formSuccessMessage.isEmpty ? 0 : 12,
              color: const Color.fromARGB(255, 0, 127, 0),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
  );

  Widget get _activitiesInput => Padding(
    padding: const EdgeInsets.all(40),
    child: Form(
      key: widget.formKey,
      child: Column(
        children: [
          Row(children: [
            const Text(
              "Activity Type:", 
              textAlign: TextAlign.left, 
              style: TextStyle(fontSize: 16)
            ),
            const SizedBox(width: 48),
            Expanded(child: DropdownButton<ActivityType>(  
              isExpanded: true,          
              borderRadius: BorderRadius.circular(8),
              value: _activityType,
              items: ActivityType.values.map((t) => DropdownMenuItem(
                  value: t, child: Text("\t${t.capitalised}")
              )).toList(), 
           onChanged: (state) {
                        setState(() {
                          _activityType = state!;
                        });
                        reCalculateCalsBurnt();
                      }
            ))
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Text(
              "Activity Intensity:", 
              textAlign: TextAlign.left, 
              style: TextStyle(fontSize: 16)
            ),
            const SizedBox(width: 20),
            Expanded(child: DropdownButton<ActivityIntensity>(  
              isExpanded: true,          
              borderRadius: BorderRadius.circular(8),
              value: _activityIntensity,
              items: ActivityIntensity.values.map((t) => DropdownMenuItem(
                  value: t, child: Text("\t${t.capitalised}")
              )).toList(), 
           onChanged: (state) {
                        setState(() {
                          _activityIntensity = state!;
                        });
                        reCalculateCalsBurnt();
                      }
            ))
          ]),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: _inputController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
               onChanged: (value) {
                setState(() {
                  int? currentDuration = int.tryParse(_inputController.text);
                  //only allows the calories to be changed once the duration is entered
                  isCaloriesInputEnabled = currentDuration != null &&
                      currentDuration > 0 &&
                      _inputController.text.trim().isNotEmpty;
                });
                reCalculateCalsBurnt();
              },
            decoration: const InputDecoration(labelText: "Duration (Minutes)"),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => _validateInputs && value != null &&
              (int.tryParse(value.trim()) == null || int.parse(value.trim()) < 0)
              ? "Please enter a positive integer value." : null,
          ),
        
                const SizedBox(height: 50),
            Row(children: [
            Text(
              _activityType == ActivityType.other 
                ? "unable to estimate calories burnt when the activity is other"
                :  calsBurnt == -1 
                  ? "enter the duration for a calorie estimate" 
                  : "according to our estimates, you would have burnt $calsBurnt calories", 
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 16)
            ),
            ]),
            TextFormField(
              enabled: isCaloriesInputEnabled,
              keyboardType: TextInputType.number,
              controller: _calorieInputController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: "Calories burnt"),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => _validateInputs &&
                      value != null &&
                      (int.tryParse(value.trim()) == null ||
                          int.parse(value.trim()) < 0)
                  ? "Please enter a positive integer value."
                  : null,
            ),
              const SizedBox(height: 20),
          Button(
            buttonText: "Log Activity",
            onPressed: logActivity,
            width: double.infinity,
          ),
          const SizedBox(height: 6),
          Text(
            _formSuccessMessage, 
            style: TextStyle(
              fontSize: _formSuccessMessage.isEmpty ? 0 : 12,
              color: const Color.fromARGB(255, 0, 127, 0),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
  );

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: const Text("Log Data"),
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
    body: Column(children: [
      Row(children: [
        // Text to tell the user to select a database
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Select type of data to log: ", 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 16
            )
          )
        ),
        // Dropdown button to select table
        Expanded(child: Padding(
          padding: const EdgeInsets.all(16), 
          child: DropdownButton<DatabaseTypes>(  
            isExpanded: true,          
            borderRadius: BorderRadius.circular(8),
            value: _currentDatabase,
            items: DatabaseTypes.values.map((t) => DropdownMenuItem(
                value: t, child: Text("\t${t.capitalised}")
            )).toList(), 
            onChanged: (state) => setState(() {
              _currentDatabase = state!;
              resetState("");
            })
          )
        ))
      ]),

      {
        DatabaseTypes.steps: _stepsInput,
        DatabaseTypes.mood: _moodInput,
        DatabaseTypes.activities: _activitiesInput,
      }[_currentDatabase]!
    ]),
  );

  bool validateInput() {
    setState(() {
      _validateInputs = true;
      _formSuccessMessage = "";
    });
    return widget.formKey.currentState!.validate();
  }

  void showLoadingSymbol(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => const Center(child: CircularProgressIndicator()), 
    );
  }

  void resetState(String successMessage) {
    _validateInputs = false;
    _inputController.clear();
    _formSuccessMessage = successMessage;
  }

  Future<void> logSteps(BuildContext context) async {
    if (!validateInput()) return;
    showLoadingSymbol(context);
    await UserData.instance!.addSteps(int.parse(_inputController.text.trim()));
    setState(() => resetState("Steps entry added successfully"));
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> logMood(BuildContext context) async {
    if (!validateInput()) return;
    showLoadingSymbol(context);
    await UserData.instance!.addMood(int.parse(_inputController.text.trim()));
    setState(() => resetState("Mood entry added successfully"));
    if (context.mounted) Navigator.of(context).pop();
  }

 Future<void> logActivity(BuildContext context) async {
    if (!validateInput()) return;
    showLoadingSymbol(context);
    await UserData.instance!.addActivity(
        _activityType,
        _activityIntensity,
        int.parse(_inputController.text.trim()),
        int.parse(_calorieInputController.text.trim()));
    setState(() => resetState("Activity entry added successfully"));
    if (context.mounted) Navigator.of(context).pop();
  }
}