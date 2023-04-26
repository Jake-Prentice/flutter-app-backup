import 'package:flutter/material.dart';
import 'package:flutter_pi/services/notifications.dart';
import 'package:flutter_pi/services/sendmail.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class IconBlob extends StatelessWidget {
  const IconBlob({
    super.key,
    required this.icon,
    required this.email,
  });
  final IconData? icon;
  final String email;

  @override
  Widget build(BuildContext context) {
    tz.initializeTimeZones();
    Map<int, String> options = {};
    // Future <Map<int, String>> options = await notificationService.mapReturn();
    final now=tz.TZDateTime.now(tz.local);
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title:const Text('Notification settings'),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () async{
                    TimeOfDay time = TimeOfDay(hour: now.hour+1, minute: now.minute);
                    TimeOfDay? newTime = await showTimePicker(context: context,
                        initialTime: time);
                    options = await NotificationService().mapReturn();
                    if(newTime!=null) {
                      NotificationService().showNotification(
                          title: "PI app log activity",
                          body: "It's ${newTime.hour}:${newTime.minute}! Don't forget to log your activity!", email:email,
                          hours: newTime.hour, minutes:newTime.minute);
                    }
                  },
                  child:const Text('- Set daily notifications'),
                ),
                SimpleDialogOption(
                  onPressed: () async{
                    options = await NotificationService().mapReturn();
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          title: const Text('Remove by a click'),
                          children: options.entries.map((MapEntry<int, String> entry) {
                            return SimpleDialogOption(
                              onPressed: () {
                                NotificationService().cancelOneNotification(entry.key);
                                Navigator.pop(context);
                              },
                              child: Text(entry.value),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                  child: const Text('- Show current notifications'),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    NotificationService().cancelAllNotifications();
                  },
                  child: const Text('- Remove all current notification'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
