import 'package:flutter/material.dart';
import 'package:flutter_pi/buttons/button.dart';

// Class for a Button which opens a simple Dialog Box
class DialogButton extends Button {
  // Constructs a new dialog button
  DialogButton({
    super.key,
    required super.buttonText,
    super.width,
    super.height,
    super.textSize,
    this.dialogTitle,
    this.dialogText,
  }) : super(onPressed: (BuildContext context) {
    // Creates title and actions for the dialog box
    Widget title = Text(dialogTitle ?? buttonText);
    List<Widget> actions = [
      TextButton(
        onPressed: () => Navigator.pop(context, 'OK'),
        child: const Text('OK'),
      ),
    ];

    // Shows the dialog box, accounting for case when dialogText is null
    showDialog(
      context: context,
      builder: (context) => dialogText == null ? 
        AlertDialog(title: title, actions: actions) : 
        AlertDialog(title: title, actions: actions, content: Text(dialogText))
    );
  });

  // The title of the dialog box
  final String? dialogTitle;

  // The text in the main body of the dialog box
  final String? dialogText;
}