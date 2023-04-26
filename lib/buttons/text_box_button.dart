import 'package:flutter/material.dart';
import 'package:flutter_pi/buttons/button.dart';
import 'package:flutter/services.dart';

// Class to represent a text button action
class DialogAction {
  String text;
  Function(TextEditingController)? onPressed;

  DialogAction (this.text, this.onPressed);
}

// Class for a button which opens a dialog box with a text box
class TextBoxDialogButton extends Button {
  // Text controller for the text boxes
  static final _textController = TextEditingController(); 

  // Default dialog actions
  static final List<DialogAction> defaultActions = [
      DialogAction("Submit", null),
      DialogAction("Cancel", null)
  ];

  // Constructs a new text box dialog button
  TextBoxDialogButton({
    super.key,
    required super.buttonText,
    super.width,
    super.height,
    super.textSize,
    this.dialogTitle,
    this.textBoxHint,
    this.dialogActions,
  }) : super(onPressed: (BuildContext context) {
    Widget title = Text(dialogTitle ?? buttonText);

    // Uses DialogAction list to generate TextButton action widgets
    List<Widget> actions = [];
    for (DialogAction dialogAction in dialogActions ?? defaultActions) {
      actions.add(TextButton(
        child: Text(dialogAction.text),
        onPressed: () {
          if (dialogAction.onPressed != null) {
            dialogAction.onPressed!(_textController);
          }
          Navigator.pop(context, 'OK');
        },
      ));
    }

    // Shows the dialog box, with the text box and all of the specified actions
    _textController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: title, actions: actions, 
        content: TextField(
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          controller: _textController,
          decoration: InputDecoration(
            hintText: textBoxHint,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () {
                _textController.clear();
              },
              icon: const Icon(Icons.clear),
            )
          ),
        )
      )
    );
  });

  // The title of the dialog box
  final String? dialogTitle;

  // The hint for the text box
  final String? textBoxHint;

  // A list of DialogAction objects for the dialog box's text buttons
  final List<DialogAction>? dialogActions;
}