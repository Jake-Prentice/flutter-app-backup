import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_pi/services/sendmail.dart';

class NotificationService {// Required variable
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static int notificationId = 0;
  static Map<int,String> NotifsTime = {};
  Future<void> cancelAllNotifications() async {
    for (int id in NotifsTime.keys) {
      await notificationsPlugin.cancel(id);
    }
    NotifsTime.clear();
    notificationId=1;
    // Cancel all currently displayed notifications
  }
  Future<void> cancelOneNotification(id) async {
    await notificationsPlugin.cancel(id);
    NotifsTime.remove(id);
    // Cancel all currently displayed notifications
  }
  Future<Map<int,String>> mapReturn() async {
    return NotifsTime;
    // Cancel all currently displayed notifications
  }
  Future<void> initNotification({required String email,}) async {
    tz.initializeTimeZones();
    AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('flutter_logo');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {

    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification({
    //int id = 0,
    String? title,
    String? body,
    String? payLoad,
    required String email,
    required hours,
    required minutes,
  }) async {
    await initNotification(email:email); // ensure the notification plugin is initialized
    // send email when notification is triggered await sendMail(email: email);
    // if(hours==24)
    //   hours=0;
    String hour_minutes = hours.toString() + ":" + minutes.toString();
    print(NotifsTime.keys);
    if (NotifsTime.containsValue(hour_minutes)) {
      print('Name key exists in the map');
    } else {
      print('Name key does not exist in the map');
      NotifsTime[notificationId]=hour_minutes;
      print(NotifsTime);
      notificationId++;
    }
    return notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      _scheduleDaily(Time(hours, minutes)),
      await notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _scheduleDaily(Time time)
  {
    final now=tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour-1,
      time.minute,
    );
    return scheduledDate.isBefore(now)
        ? scheduledDate.add(Duration(days:1))
        : scheduledDate;
  }
}
