// https://github.com/bluefireteam/audioplayers/blob/main/getting_started.md

import 'package:alarm_cycle/services/alarm_service.dart';
import 'package:alarm_cycle/util/date_time_parser.dart';
import 'package:alarm_cycle/viewmodels/alarm_vm.dart';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/alarm.dart';

const String appName = "Alarm Manager Example";

class MyHomePage extends StatelessWidget {
  final String title;
  final String minutesLabel = "Minutes";
  final String hoursLabel = "Hours";
  final String periodicAlarmLabel = "Periodic";
  final String deleteAlarmLabel = "Delete";
  final String addAlarmLabel = "Add Alarm";
  final String editAlarmLabel = "Edit Alarm";
  final String alarmListLabel = "Alarms";

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
            Text(
              alarmListLabel,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            Expanded(
              child: Consumer<AlarmVM>(
                builder: (context, alarmVM, child) {
                  List<Alarm> alarms = alarmVM.alarmLst;
                  return ListView.builder(
                    itemCount: alarms.length,
                    itemBuilder: (context, index) {
                      Alarm alarm = alarms[index];
                      return ListTile(
                        title: Text(alarm.title),
                        subtitle: Text(alarm.description),
                        onTap: () {
                          _showAlarmDetailsDialog(context, alarm);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 112,
                  height: 50,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        _showAddAlarmDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: Text(addAlarmLabel)),
                ),
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                  width: 112,
                  height: 50,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        _showEditAlarmDialog(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(editAlarmLabel)),
                ),
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                  width: 112,
                  height: 50,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        _showDeleteAlarmDialog(context);
                      },
                      icon: const Icon(Icons.watch_later_outlined),
                      label: Text(deleteAlarmLabel)),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAlarmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String alarmId = '';
        return AlertDialog(
          title: const Text('Delete Alarm'),
          content: TextField(
            onChanged: (value) {
              alarmId = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter Alarm ID',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Provider.of<AlarmVM>(context, listen: false)
                    .deletePeriodicAlarm(
                  alarmId: int.parse(alarmId),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAlarmDetailsDialog(BuildContext context, Alarm alarm) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(alarm.title),
            // content: Text(alarm.description),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    const Text(
                      'Alarm ID: ',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      alarm.alarmId.toString(),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Description: ',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      alarm.description,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Periodicity: ',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      alarm.alarmHHmmPeriodicity,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Start date tine: ',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      DateTimeParser.englishDateTimeFormat
                          .format(alarm.startAlarmDateTime),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),

            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _showAddAlarmDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController periodicityController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Alarm'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                  ),
                ),
                TextField(
                  controller: periodicityController,
                  decoration: const InputDecoration(
                    hintText: 'HH:mm periodicity',
                  ),
                ),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(
                    hintText: 'Alarm start HH:mm time',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await Provider.of<AlarmVM>(context, listen: false).addAlarm(
                    title: titleController.text,
                    description: descriptionController.text,
                    alarmHHmmPeriodicity: periodicityController.text,
                    startAlarmHHmm: startTimeController.text,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
  }

  void _showEditAlarmDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    AlarmVM alarmVM = Provider.of<AlarmVM>(context, listen: false);
    Alarm selectedAlarm = alarmVM.selectedAlarm();
    titleController.text = selectedAlarm.title;
    descriptionController.text = selectedAlarm.description;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Alarm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AlarmVM>(context, listen: false).editAlarm(
                  alarmId: selectedAlarm.alarmId,
                  title: titleController.text,
                  description: descriptionController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
      create: (context) => AlarmVM(AlarmService()),
      child: const MyApp(),
    ),
  );
}
