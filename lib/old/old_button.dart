import 'package:flutter/material.dart';

class OldButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget child;
  final String title;
  final String content;

  const OldButton({
    Key? key,
    this.onPressed,
    required this.child,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            ConstrainedBox(
              constraints:
              const BoxConstraints.tightFor(width: 300, height: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: onPressed ??
                        () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(title),
                      content: Text(content),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  );
                },
                child: child,
              ),
            ),
        ],
      ),
    );
  }
}