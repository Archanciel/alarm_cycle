// https://github.com/bluefireteam/audioplayers/blob/main/getting_started.md

import 'package:alarm_cycle/services/alarm_service.dart';
import 'package:alarm_cycle/util/date_time_parser.dart';
import 'package:alarm_cycle/viewmodels/alarm_vm.dart';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:provider/provider.dart';

import 'models/alarm.dart';

const String appName = "Periodic Alarm Manager";

class MyHomePage extends StatelessWidget {
  final String title;
  final String deleteAlarmLabel = "Delete Alarm";
  final String addAlarmLabel = "Add Alarm";
  final String editAlarmLabel = "Edit Alarm";
  final String detailAlarmLabel = "Detail Alarm";
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
            const SizedBox(
              height: 15,
            ),
            Text(
              alarmListLabel,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            Expanded(
              child: Consumer<AlarmVM>(
                builder: (context, alarmVM, child) {
                  Map<int, Alarm> alarmsMap = alarmVM.alarmsMap;
                  List<Alarm> alarmsLst = alarmsMap.values.toList();
                  return ListView.builder(
                    itemCount: alarmsMap.length,
                    itemBuilder: (context, index) {
                      Alarm alarm = alarmsLst[index];
                      final color =
                          Colors.primaries[index % Colors.primaries.length];
                      final bool isAlarmSelected =
                          alarmVM.selectedAlarmId == alarm.alarmId;
                      return Container(
                        color: isAlarmSelected ? color.withOpacity(0.3) : null,
                        child: ListTile(
                          title: Text(
                            alarm.title,
                            style: TextStyle(color: color),
                          ),
                          subtitle: Text(
                            alarm.description,
                            style: TextStyle(color: color),
                          ),
                          onTap: () {
                            alarmVM.selectAlarm(
                              alarmId: alarm.alarmId,
                            );
                            // _showAlarmDetailsDialog(context, alarm);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Column(
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
                  height: 5,
                ),
                SizedBox(
                  width: 112,
                  height: 50,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        _showDetailsAlarmDialog(context);
                      },
                      icon: const Icon(Icons.details),
                      label: Text(detailAlarmLabel)),
                ),
                const SizedBox(
                  height: 5,
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
                  height: 5,
                ),
                SizedBox(
                  width: 112,
                  height: 50,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        _showDeleteAlarmDialog(context);
                      },
                      icon: const Icon(Icons.delete),
                      label: Text(deleteAlarmLabel)),
                ),
                const SizedBox(
                  height: 5,
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
    AlarmVM alarmVM = Provider.of<AlarmVM>(context, listen: false);
    Alarm selectedAlarm = alarmVM.getSelectedAlarm();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Alarm'),
          content: _buildDisplayedAlarm(selectedAlarm),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await Provider.of<AlarmVM>(context, listen: false).deleteAlarm(
                  alarmId: selectedAlarm.alarmId,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDetailsAlarmDialog(BuildContext context) {
    AlarmVM alarmVM = Provider.of<AlarmVM>(context, listen: false);
    Alarm selectedAlarm = alarmVM.getSelectedAlarm();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(selectedAlarm.title),
            // content: Text(alarm.description),
            content: _buildDisplayedAlarm(selectedAlarm),
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

  /// Build non editable alarm details
  Column _buildDisplayedAlarm(Alarm selectedAlarm) {
    return Column(
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
              selectedAlarm.alarmId.toString(),
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
              selectedAlarm.description,
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
              selectedAlarm.alarmHHmmPeriodicity,
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
                  .format(selectedAlarm.startAlarmDateTime),
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ],
    );
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
            content: _buildEditableAlarm(
              titleController: titleController,
              descriptionController: descriptionController,
              periodicityController: periodicityController,
              startTimeController: startTimeController,
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

  Column _buildEditableAlarm({
    required TextEditingController titleController,
    required TextEditingController descriptionController,
    required TextEditingController periodicityController,
    required TextEditingController startTimeController,
  }) {
    return Column(
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
    );
  }

  void _showEditAlarmDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController periodicityController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    AlarmVM alarmVM = Provider.of<AlarmVM>(context, listen: false);
    Alarm selectedAlarm = alarmVM.getSelectedAlarm();
    titleController.text = selectedAlarm.title;
    descriptionController.text = selectedAlarm.description;
    periodicityController.text = selectedAlarm.alarmHHmmPeriodicity;
    startTimeController.text = DateTimeParser.englishDateTimeFormat
        .format(selectedAlarm.startAlarmDateTime);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Alarm'),
          content: _buildEditableAlarm(
            titleController: titleController,
            descriptionController: descriptionController,
            periodicityController: periodicityController,
            startTimeController: startTimeController,
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
