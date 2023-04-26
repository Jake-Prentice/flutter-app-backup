import 'package:flutter/material.dart';
import 'package:flutter_pi/user_data/user_data.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Achievement {
  Achievement({
    required this.name,
    required this.iconName,
    required this.levels,
    required this.getDescription,
    required this.getProgress
  });

  Widget build(BuildContext context) {
    int progress = getProgress(UserData.instance!);
    int level;
    for (level = 0; level < levels.length && progress >= levels[level]; level++) {}
    bool completed = level >= levels.length;
    int goal = completed ? levels[level - 1] : levels[level];
    return Container(
      width: double.infinity,
      height: 85,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(16)
      ),
      padding: const EdgeInsets.all(16), 
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage("assets/images/$iconName.png"),
                fit:  BoxFit.contain
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$name - ${completed ? "Complete" : "Level ${level + 1}"}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(getDescription(goal), style: const TextStyle(fontSize: 14)),
              ]
            ),
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: CircularPercentIndicator(
              radius: 20,
              lineWidth: 10,
              animation: true,
              animateFromLastPercent: true,
              animationDuration: 800,
              percent: completed ? 1 : progress / goal,
              progressColor: Theme.of(context).buttonTheme.colorScheme!.primary,
            ),
          )
        ],
      ) 
    );
  }

  final String name;
  final String iconName;
  final List<int> levels;
  final String Function(int) getDescription;
  final int Function(UserData) getProgress;
}