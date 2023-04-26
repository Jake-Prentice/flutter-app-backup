import 'package:flutter/material.dart';
import 'package:flutter_pi/buttons/button.dart';
import 'package:flutter_pi/services/notifications.dart';
import 'package:flutter_pi/buttons/text_box_button.dart';
import 'package:flutter_pi/user_data/user_data.dart';

class MoodHistory extends StatefulWidget {
  const MoodHistory({super.key, required this.userData});

  // User data to be displayed in the table
  final UserData userData;

  @override
  State<MoodHistory> createState() => _MoodHistoryState();
}

class _MoodHistoryState extends State<MoodHistory> {
  // Text colours for mood history table
  final greenText = TextStyle(fontSize: 18, color: Colors.green[300]);
  final yellowText = const TextStyle(fontSize: 18, color: Color(0xFFE0D948));
  final orangeText = const TextStyle(fontSize: 18, color: Color(0xFFEAA134));
  final redText = TextStyle(fontSize: 18, color: Colors.red[300]);
  final titleText = const TextStyle(fontSize: 25, color: Colors.white);
  final normalText = const TextStyle(fontSize: 18, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Track your mood")
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(40),
        children: [
          const SizedBox(height: 30),
          Button(
            buttonText: "Set the schedule of notifications",
            onPressed: (BuildContext context) {
            },
          ),
          const SizedBox(height: 15),
          TextBoxDialogButton(
            buttonText: "Log your current mood",
            textBoxHint: "Enter a digit on a scale 1-10",
            textSize: 16,
            dialogActions: [
              DialogAction("Submit", (t) {
                int? mood = int.tryParse(t.text);
                if (mood != null && mood>= 1 && mood<=10) {
                  setState(() { widget.userData.addMood(mood); });
                }
              }),
              DialogAction("Cancel", (_) {})
            ],
          ),
          const SizedBox(height: 40),
          IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(width:200, child: Text("Date", textAlign: TextAlign.center, style:titleText)),
                          const SizedBox(height:10),
                          //for (OldDataEntry entry in widget.userData.data.getEntries(EntryType.mood).reversed)
                          //  SizedBox(width:300, child: Text(
                          //      "${entry.date.day}/${entry.date.month}/${entry.date.year}",
                          //      textAlign: TextAlign.center,
                          //      style:normalText
                          //  )
                          //),
                        ]
                    )
                ),
                VerticalDivider(thickness: 1, color: Theme.of(context).secondaryHeaderColor,),
                Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width:200, child: Text("Mood", textAlign: TextAlign.center, style:titleText)),
                        const SizedBox(height:10),
                      ],
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}