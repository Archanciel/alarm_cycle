// https://github.com/bluefireteam/audioplayers/blob/main/getting_started.md

import 'package:alarm_cycle/services/alarm_service.dart';
import 'package:alarm_cycle/viewmodels/alarm_vm.dart';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const String appName = "Alarm Manager Example";

class MyHomePage extends StatelessWidget {
  final String title;
  final String minutesLabel = "Minutes";
  final String hoursLabel = "Hours";
  final String periodicAlarmLabel = "Periodic";
  final String deleteAlarmLabel = "Delete";

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              appName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 112,
                  height: 50,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        String alarmHHmmPeriodicity =
                            await _chooseDuration(context);
                        Provider.of<AlarmViewModel>(context, listen: false)
                            .schedulePeriodicAlarm(
                          alarmHHmmPeriodicity: alarmHHmmPeriodicity,
                          startAlarmHHmm: DateTime.now().toString(),
                        );
                      },
                      icon: const Icon(Icons.watch_later_outlined),
                      label: Text(periodicAlarmLabel)),
                ),
                const SizedBox(
                  width: 16,
                ),
                SizedBox(
                  width: 112,
                  height: 50,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        Provider.of<AlarmViewModel>(context, listen: false)
                            .deletePeriodicAlarm(
                          alarmHHmmPeriodicity: '',
                          startAlarmHHmm: DateTime.now().toString(),
                        );
                      },
                      icon: const Icon(Icons.watch_later_outlined),
                      label: Text(deleteAlarmLabel)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<String> _chooseDuration(BuildContext context) async {
    String alarmPeriodicityHHmmStr = '';
    String? alarmPeriodicityValueTypeStr;

    String? enteredText = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Enter a number for the duration"),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RadioListTile(
                          title: Text(minutesLabel),
                          value: minutesLabel,
                          groupValue: alarmPeriodicityValueTypeStr,
                          onChanged: (String? value) {
                            setState(
                                () => alarmPeriodicityValueTypeStr = value);
                          }),
                    ),
                    Expanded(
                      child: RadioListTile(
                          title: Text(hoursLabel),
                          value: hoursLabel,
                          groupValue: alarmPeriodicityValueTypeStr,
                          onChanged: (String? value) {
                            setState(
                                () => alarmPeriodicityValueTypeStr = value);
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (String text) {
                              alarmPeriodicityHHmmStr = text;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(alarmPeriodicityHHmmStr);
                },
                child: const Text("Ok"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              )
            ],
          );
        });

    if (enteredText != null) {
      int enteredTextInt = int.parse(enteredText);

      if (alarmPeriodicityValueTypeStr == minutesLabel) {
        if (enteredTextInt > 9) {
          return '00:$enteredText';
        } else {
          return '00:0$enteredText';
        }
      } else {
        return '$enteredText:00';
      }
    }

    return alarmPeriodicityHHmmStr;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: appName),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AlarmViewModel(AlarmService()),
      child: const MyApp(),
    ),
  );
}
