import 'package:flutter/material.dart';

// General Button class that can perform a function when pressed
class Button extends StatelessWidget {
  // Button constructor
  const Button({
    super.key,
    required this.buttonText, 
    this.width,
    this.height,
    this.textSize,
    this.onPressed, 
  });

  // Text written on the button
  final String buttonText;  

  // Appearance Settings
  final double? width;
  final double? height;
  final double? textSize;

  // Function to run when the button is pressed
  final Function(BuildContext)? onPressed;  

  @override
  // Builds Button widget
  Widget build(BuildContext context) =>  SizedBox(
    height: height ?? 50, width: width ?? 250,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed != null ? () => onPressed!(context) : null,
      child: Text(
        buttonText,
        style: TextStyle(fontSize: textSize ?? 16),
      ),
    ),
  );
}