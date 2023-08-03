import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';

const String appName = "Alarm Manager Example";
const String durationMinutes = "Minutes";
const String durationHours = "Hours";
const String periodicAlarm = "periodic";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _periodicTaskId = 3;

  static void _periodicTaskCallback() {
    print("Periodic Task Running. Time is ${DateTime.now()}");
  }

  void _schedulePeriodicAlarm() async {
    Duration duration = await _chooseDuration();
    await AndroidAlarmManager.periodic(
        duration, _periodicTaskId, _periodicTaskCallback);
  }

  Future<Duration> _chooseDuration() async {
    String duration = "";
    String durationString = durationMinutes;
    AlertDialog alert = AlertDialog(
      title: const Text("Enter a number for the duration"),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: RadioListTile(
                    title: const Text(durationMinutes),
                    value: durationMinutes,
                    groupValue: durationString,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => durationString = value);
                      }
                    }),
              ),
              Expanded(
                child: RadioListTile(
                    title: const Text(durationHours),
                    value: durationHours,
                    groupValue: durationString,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => durationString = value);
                      }
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (String text) {
                        duration = text;
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
            Navigator.of(context).pop(duration);
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

    String? enteredText = await showDialog(
        context: context,
        builder: (context) {
          return alert;
        });

    if (enteredText != null) {
      int time = int.parse(enteredText);
      if (durationString == durationMinutes) {
        return Duration(minutes: time);
      } else {
        return Duration(hours: time);
      }
    }
    return const Duration(seconds: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                      onPressed: _schedulePeriodicAlarm,
                      icon: const Icon(Icons.watch_later_outlined),
                      label: const Text(periodicAlarm)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
