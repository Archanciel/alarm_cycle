import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const String appName = "Alarm Manager Example";
const String durationMinutes = "Minutes";
const String durationHours = "Hours";
const String periodicAlarm = "periodic";

class AlarmService {
  static const int _periodicTaskId = 3;
  
  static void _periodicTaskCallback() {
    print("Periodic Task Running. Time is ${DateTime.now()}");
  }

  Future<void> schedulePeriodicAlarm(Duration duration) async {
    await AndroidAlarmManager.periodic(
        duration, _periodicTaskId, _periodicTaskCallback);
  }
}

class AlarmViewModel extends ChangeNotifier {
  final AlarmService _alarmService;

  AlarmViewModel(this._alarmService);

  Future<void> schedulePeriodicAlarm(Duration duration) async {
    await _alarmService.schedulePeriodicAlarm(duration);
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

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
                        Duration duration = await _chooseDuration(context);
                        Provider.of<AlarmViewModel>(context, listen: false)
                            .schedulePeriodicAlarm(duration);
                      },
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

  Future<Duration> _chooseDuration(BuildContext context) async {
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
}

class MyApp extends StatelessWidget {
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
      child: MyApp(),
    ),
  );
}
