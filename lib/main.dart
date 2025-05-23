// Flutter MVVM Alarm App
// https://chat.openai.com/share/123e52e0-ccdc-4087-9c4d-409366372116

import 'package:alarm_cycle/constant.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/alarm_vm.dart';
import 'views/alarm_page.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  final alarmVM = AlarmVM();
  await alarmVM.checkAlarmsPeriodically(task.taskId);
}

void main() {
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  final alarmVM = AlarmVM(); // s'assure que c'est l'instance unique

  runApp(ChangeNotifierProvider(
    create: (context) => alarmVM,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      navigatorKey: navigatorKey,
      home: const AlarmPage(),
    );
  }
}
