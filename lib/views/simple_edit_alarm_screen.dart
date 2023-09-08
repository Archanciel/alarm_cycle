
import 'package:alarm_cycle/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/alarm.dart';
import '../util/date_time_parser.dart';
import '../viewmodels/alarm_vm.dart';

class SimpleEditAlarmScreen extends StatefulWidget {
  final Alarm alarm;

  const SimpleEditAlarmScreen({super.key, required this.alarm});

  @override
  _SimpleEditAlarmScreenState createState() => _SimpleEditAlarmScreenState(
        alarm: alarm,
      );
}

class _SimpleEditAlarmScreenState extends State<SimpleEditAlarmScreen> with ScreenMixin {
  final Alarm _alarm;

  _SimpleEditAlarmScreenState({
    required Alarm alarm,
  }) : _alarm = alarm;

  // Your simple edit logic here, maybe just a few key fields rather than everything.
  @override
  void initState() {
    super.initState();

    // Set the value of the dropdown button menu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AlarmVM>(context, listen: false).selectedAudioFile =
          _alarm.audioFilePathName.split('/').last;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: _alarm.name);
    TextEditingController timeController = TextEditingController(
        text: DateTimeParser.HHmmDateTimeFormat.format(_alarm.nextAlarmTime));
    TextEditingController durationController = TextEditingController(
        text:
            "${_alarm.periodicDuration.inHours.toString().padLeft(2, '0')}:${(_alarm.periodicDuration.inMinutes % 60).toString().padLeft(2, '0')}");

    List<Widget> alarmEditionWidgetLst = createAlarmEditionWidgetLst(
      nameController: nameController,
      timeController: timeController,
      periodicityDurationController: durationController,
      isNextAlarmClearButtonDisplayed: true,
      isPeriodicityClearButtonDisplayed: true,
    );

    alarmEditionWidgetLst.add(Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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
            _alarm.name = nameController.text;

            _alarm.nextAlarmTime = extractNextAlarmDateTime(
              nextAlarmTimeStr: timeController.text,
              currentAlarmDateTime: _alarm.nextAlarmTime,
            );

            // enabling the user to enter a periodicity in a
            // simplified format (e.g. 1:30 for 01:30 or 5 for
            // 05:00.
            final String formattedHhMmPeriodicityStr =
                DateTimeParser.formatStringDuration(
              durationStr: durationController.text,
            );
            _alarm.periodicDuration = Duration(
              hours: int.parse(formattedHhMmPeriodicityStr.split(':')[0]),
              minutes: int.parse(formattedHhMmPeriodicityStr.split(':')[1]),
            );

            AlarmVM alarmVM = Provider.of<AlarmVM>(context, listen: false);
            _alarm.audioFilePathName = alarmVM.selectedAudioFile;
            alarmVM.editAlarm(_alarm);

            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Alarm"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: alarmEditionWidgetLst,
        ),
      ),
    );
  }
}
