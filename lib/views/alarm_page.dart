import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constant.dart';
import '../models/alarm.dart';
import '../services/permission_requester_service.dart';
import '../util/date_time_parser.dart';
import '../viewmodels/alarm_vm.dart';
import 'screen_mixin.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({
    super.key,
  });

  @override
  _AlarmPageState createState() => _AlarmPageState();

  Widget createInfoRowFunction({
    Key? valueTextWidgetKey, // key set to the Text widget displaying the value
    required BuildContext context,
    required String label,
    required String value,
    bool isTextBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: kFontSize,
              fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          child: Text(
            key: valueTextWidgetKey,
            value,
            style: TextStyle(
              fontSize: kFontSize,
              fontWeight: isTextBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _AlarmPageState extends State<AlarmPage> with ScreenMixin {
  @override
  void initState() {
    super.initState();

    PermissionRequesterService.requestMultiplePermissions();

    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
      AlarmVM().checkAlarmsPeriodically,
    );

    BackgroundFetch.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alarm Manager")),
      body: Consumer<AlarmVM>(
        builder: (context, viewModel, child) => ListView.builder(
          itemCount: viewModel.alarms.length,
          itemBuilder: (context, index) {
            final alarm = viewModel.alarms[index];
            return Container(
              margin: const EdgeInsets.symmetric(
                vertical: 2, // determines the vertical space
                //              between each ListTile
              ),
              child: ListTile(
                title: Text(
                  alarm.name,
                  style: const TextStyle(
                    fontSize: kFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                subtitle: InkWell(
                  onTap: () {
                    _showEditAlarmDialog(alarm);
                  },
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Aligns the text to the left
                    children: [
                      widget.createInfoRowFunction(
                        context: context,
                        label: 'Real alarm: ',
                        value: (alarm.lastAlarmTimeReal == null)
                            ? ''
                            : DateTimeParser.frenchDateTimeFormat
                                .format(alarm.lastAlarmTimeReal!),
                      ),
                      widget.createInfoRowFunction(
                        context: context,
                        label: 'Last alarm: ',
                        value: (alarm.lastAlarmTimePurpose == null)
                            ? ''
                            : DateTimeParser.frenchDateTimeFormat
                                .format(alarm.lastAlarmTimePurpose!),
                      ),
                      widget.createInfoRowFunction(
                        context: context,
                        label: 'Next alarm: ',
                        value: DateTimeParser.frenchDateTimeFormat
                            .format(alarm.nextAlarmTime),
                        isTextBold: true,
                      ),
                      widget.createInfoRowFunction(
                        context: context,
                        label: 'Periodicity:',
                        value:
                            '${alarm.periodicDuration.inHours.toString().padLeft(2, '0')}:${(alarm.periodicDuration.inMinutes % 60).toString().padLeft(2, '0')}',
                      ),
                      widget.createInfoRowFunction(
                        context: context,
                        label: 'Audio file:',
                        value: alarm.audioFilePathName.split('/').last,
                      ),
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => viewModel.deleteAlarm(index),
                ),
                onTap: () {
                  _showEditAlarmDialog(alarm);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          Alarm? newAlarm = await _showAddAlarmDialog(context);
          if (newAlarm != null) {
            // Assuming you have a method in your ViewModel to add alarms
            Provider.of<AlarmVM>(context, listen: false).addAlarm(newAlarm);
          }
        },
      ),
    );
  }

  Future<Alarm?> _showAddAlarmDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController timeController = TextEditingController(
        text: DateTimeParser.HHmmDateTimeFormat.format(
            DateTimeParser.truncateDateTimeToMinute(DateTime.now())));
    TextEditingController durationController = TextEditingController();

    // Set the default value of the dropdown button menu
    AlarmVM alarmVM = Provider.of<AlarmVM>(context, listen: false);
    alarmVM.selectedAudioFile = AlarmVM.audioFileNames[0];

    List<Widget> alarmEditionWidgetLst = createAlarmEditionWidgetLst(
      nameController: nameController,
      timeController: timeController,
      periodicityDurationController: durationController,
      isNextAlarmClearButtonDisplayed: true,
    );

    return showDialog<Alarm>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Alarm'),
          content: SingleChildScrollView(
            child: Column(
              children: alarmEditionWidgetLst,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                // Process the input values and create a new Alarm instance
                final name = nameController.text;

                // enabling the user to enter a next alarm time in a
                // simplified format (e.g. 9:3 for 09:30 or 15 for
                // 15:00.
                final String formattedHhMmNextAlarmTimeStr =
                    DateTimeParser.formatStringDuration(
                  durationStr: timeController.text,
                );

                DateTime? nextAlarmTime =
                    DateTimeParser.computeNextAlarmDateTime(
                  formattedHhMmNextAlarmTimeStr: formattedHhMmNextAlarmTimeStr,
                );

                // enabling the user to enter a periodicity in a
                // simplified format (e.g. 1:3 for 01:30 or 5 for
                // 05:00.
                final String formattedHhMmPeriodicityStr =
                    DateTimeParser.formatStringDuration(
                  durationStr: durationController.text,
                );

                final periodicDuration = Duration(
                  hours: int.parse(formattedHhMmPeriodicityStr.split(':')[0]),
                  minutes: int.parse(formattedHhMmPeriodicityStr.split(':')[1]),
                );

                Navigator.of(context).pop(Alarm(
                    name: name,
                    nextAlarmTime: nextAlarmTime!,
                    periodicDuration: periodicDuration,
                    audioFilePathName: alarmVM.selectedAudioFile));
              },
            ),
          ],
        );
      },
    );
  }

  _showEditAlarmDialog(Alarm alarm) {
    TextEditingController nameController =
        TextEditingController(text: alarm.name);
    DateTime nextAlarmTime = alarm.nextAlarmTime;

    String nextAlarmTimeStr = DateTimeParser.formatDateTimeHHmmOrddMMyyyyHHmm(
      dateTime: nextAlarmTime,
    );

    TextEditingController timeController =
        TextEditingController(text: nextAlarmTimeStr);
    TextEditingController durationController = TextEditingController(
        text:
            "${alarm.periodicDuration.inHours.toString().padLeft(2, '0')}:${(alarm.periodicDuration.inMinutes % 60).toString().padLeft(2, '0')}");

    // Set the value of the dropdown button menu
    AlarmVM alarmVM = Provider.of<AlarmVM>(context, listen: false);
    alarmVM.selectedAudioFile = alarm.audioFilePathName.split('/').last;

    List<Widget> alarmEditionWidgetLst = createAlarmEditionWidgetLst(
      nameController: nameController,
      timeController: timeController,
      periodicityDurationController: durationController,
      isNextAlarmClearButtonDisplayed: true,
      isPeriodicityClearButtonDisplayed: true,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Alarm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: alarmEditionWidgetLst,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save Changes'),
              onPressed: () {
                // Update the current alarm's details
                alarm.name = nameController.text;

                alarm.nextAlarmTime = extractNextAlarmDateTime(
                  nextAlarmTimeStr: timeController.text,
                  currentAlarmDateTime: alarm.nextAlarmTime,
                );

                // enabling the user to enter a periodicity in a
                // simplified format (e.g. 1:3 for 01:30 or 5 for
                // 05:00.
                final String formattedHhMmPeriodicityStr =
                    DateTimeParser.formatStringDuration(
                  durationStr: durationController.text,
                );

                alarm.periodicDuration = Duration(
                  hours: int.parse(formattedHhMmPeriodicityStr.split(':')[0]),
                  minutes: int.parse(formattedHhMmPeriodicityStr.split(':')[1]),
                );
                alarm.audioFilePathName = alarmVM.selectedAudioFile;
                alarmVM.editAlarm(alarm);

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
