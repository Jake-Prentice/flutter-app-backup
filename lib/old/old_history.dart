import 'package:flutter/material.dart';
import 'package:flutter_pi/buttons/text_box_button.dart';
import 'package:flutter_pi/user_data/user_data.dart';

class OldHistory extends StatefulWidget {
  const OldHistory({super.key, required this.userData});

  // User data to be displayed in the table
  final UserData userData;

  @override
  OldHistoryState createState() => OldHistoryState();
}

class OldHistoryState extends State<OldHistory> {
  // Text colours for history table
  final greenText = TextStyle(fontSize: 18, color: Colors.green[300]);
  final redText = TextStyle(fontSize: 18, color: Colors.red[300]);
  final titleText = const TextStyle(fontSize: 25, color: Colors.white);
  final normalText = const TextStyle(fontSize: 18, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Track your steps"),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(40),
        children: [
          const SizedBox(height: 30),
          TextBoxDialogButton(
            buttonText: "Log Steps",
            textBoxHint: "Enter steps...",
            dialogActions: [
              DialogAction("Submit", (t) {
                int? steps = int.tryParse(t.text);
                if (steps != null && steps >= 0) {
                  setState(() {
                    widget.userData.addSteps(steps);
                  });                  
                }
              }),
              DialogAction("Cancel", (_) {}),
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
                          //for (OldDataEntry entry in widget.userData.data.getEntries(EntryType.steps).reversed)
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
                        SizedBox(width:200, child: Text("Steps", textAlign: TextAlign.center, style:titleText)),
                        const SizedBox(height:10),
                        //for (OldDataEntry entry in widget.userData.data.getEntries(EntryType.steps).reversed)
                        //  SizedBox(width:200, child: Text(
                        //      entry.value.toString(),
                        //      textAlign: TextAlign.center,
                        //      style: normalText
                        //    )
                        //  ),
                      ],
                    )
                  ),
                  VerticalDivider(thickness: 1, color: Theme.of(context).secondaryHeaderColor,),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width:200, child: Text("Difference", textAlign: TextAlign.center, style: titleText)),
                        const SizedBox(height: 10),
                        //for (OldDataEntry entry in widget.userData.data.getEntries(EntryType.steps).reversed)
                        //  SizedBox(
                        //    width:200,
                        //    child: Text(
                        //      (entry.value > 0 ? '+' : '') + entry.value.toString(),
                        //      textAlign: TextAlign.center,
                        //      style: entry.value >= 0 ? greenText : redText
                        //    )
                        //  )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
  }
}