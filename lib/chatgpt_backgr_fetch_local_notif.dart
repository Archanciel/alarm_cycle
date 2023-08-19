
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  runApp(const MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  AudioPlayer audioPlayer = AudioPlayer();

  await audioPlayer.play(AssetSource('audio/Sirdalud.mp3'));

  showNotification();

  // Important: end the task here, or the OS could be kill the app
  BackgroundFetch.finish(task.taskId);
}

Future<void> showNotification() async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    'alarm_notif',
    'Alarm Notifications',
    icon: '@mipmap/ic_launcher',
    channelDescription: 'Notifications for Alarm app',
    importance: Importance.max,
    priority: Priority.high,
    playSound: false, // We will play our own sound using audio player
    ongoing: true,
  );
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
      0,
      'Tâche en arrière-plan exécutée',
      'Cliquez ici pour voir plus de détails.',
      platformChannelSpecifics);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    requestMultiplePermissions();

    initPlatformState();
    initNotification();
  }

  void requestMultiplePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission
          .manageExternalStorage, // Android 11 (API level 30) or higher only
      Permission.microphone,
      Permission.mediaLibrary,
      Permission.speech,
      Permission.audio,
      Permission.videos,
      Permission.notification,
      Permission.systemAlertWindow,
      Permission.ignoreBatteryOptimizations,
    ].request();


    // Vous pouvez maintenant vérifier l'état de chaque permission
    if (!statuses[Permission.storage]!.isGranted ||
        !statuses[Permission.manageExternalStorage]!.isGranted ||
        !statuses[Permission.microphone]!.isGranted ||
        !statuses[Permission.mediaLibrary]!.isGranted ||
        !statuses[Permission.speech]!.isGranted ||
        !statuses[Permission.audio]!.isGranted ||
        !statuses[Permission.videos]!.isGranted ||
        !statuses[Permission.notification]!.isGranted) {
      // Une ou plusieurs permissions n'ont pas été accordées.
      // Vous pouvez désactiver les fonctionnalités correspondantes dans
      // votre application ou montrer une alerte à l'utilisateur.
    } else {
      // Toutes les permissions ont été accordées, vous pouvez continuer avec
      // vos fonctionnalités.
    }
  }

  Future<void> initPlatformState() async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 1,
          stopOnTerminate: false,
          enableHeadless: true,
        ), (String taskId) async {
      showNotification();
      BackgroundFetch.finish(taskId);
    });
    BackgroundFetch.start();
  }

  Future<void> initNotification() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Task Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('Background Task avec Notification')),
        body: const Center(child: Text('Consultez les notifications!')),
      ),
    );
  }
}
