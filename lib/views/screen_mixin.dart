import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constant.dart';
import '../util/date_time_parser.dart';
import '../viewmodels/alarm_vm.dart';

mixin ScreenMixin {
  DateTime extractNextAlarmDateTime({
    required String nextAlarmTimeStr,
    required DateTime currentAlarmDateTime,
  }) {
    // enabling the user to enter a next alarm time in a
    // simplified format (e.g. 9:3 for 09:30 or 15 for
    // 15:00.
    final String formattedHhMmNextAlarmTimeStr =
        DateTimeParser.formatStringDuration(
      durationStr: nextAlarmTimeStr,
    );

    DateTime? computedNextAlarmDateTime =
        DateTimeParser.computeNextAlarmDateTime(
      formattedHhMmNextAlarmTimeStr: formattedHhMmNextAlarmTimeStr,
    );

    if (computedNextAlarmDateTime != null) {
      // the entered next alarm time was a HH:mm or
      // simplified hour time
      return computedNextAlarmDateTime;
    } else {
      // the entered next alarm time was formatted as
      // dd-MM-yyyy HH:mm
      DateTime? parsedDdmmyyyyhhmmdatetime =
          DateTimeParser.parseHHmmOrddMMyyyyHHmmDateTime(
        dateTimeStr: nextAlarmTimeStr,
      );

      if (parsedDdmmyyyyhhmmdatetime != null) {
        return parsedDdmmyyyyhhmmdatetime;
      } else {
        return currentAlarmDateTime;
      }
    }
  }

  List<Widget> createAlarmEditionWidgetLst({
    required TextEditingController nameController,
    required TextEditingController timeController,
    required TextEditingController periodicityDurationController,
    bool isNextAlarmClearButtonDisplayed = false,
    bool isPeriodicityClearButtonDisplayed = false,
  }) {
    List<Widget> alarmEditionWidgetLst = [];

    alarmEditionWidgetLst.add(TextFormField(
      controller: nameController,
      decoration: const InputDecoration(
        labelText: 'Name',
        labelStyle: TextStyle(
          fontSize: kLabelStyleFontSize,
        ),
      ),
      style: const TextStyle(
        fontSize: kFontSize,
      ),
    ));
    alarmEditionWidgetLst.add(TextFormField(
      controller: timeController,
      decoration: InputDecoration(
        labelText: 'Next Alarm Time (hh:mm)',
        labelStyle: const TextStyle(
          fontSize: kLabelStyleFontSize,
        ),
        helperText:
            'If the next hh:mm alarm time is before\nthe now hh:mm time, the next alarm date\nwill be set to tomorrow. Otherwise, the\nnext alarm date will be set to today.',
        // Add the clear button to the InputDecoration
        suffixIcon: isNextAlarmClearButtonDisplayed
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => timeController.clear(),
              )
            : null,
      ),
      style: const TextStyle(
        fontSize: kFontSize,
      ),
    ));
    alarmEditionWidgetLst.add(TextFormField(
      controller: periodicityDurationController,
      decoration: InputDecoration(
        labelText: 'Periodicity (hh:mm)',
        labelStyle: const TextStyle(
          fontSize: kLabelStyleFontSize,
        ),
        // Add the clear button to the InputDecoration
        suffixIcon: isPeriodicityClearButtonDisplayed
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => periodicityDurationController.clear(),
              )
            : null,
      ),
      style: const TextStyle(
        fontSize: kFontSize,
      ),
    ));
    alarmEditionWidgetLst.add(Consumer<AlarmVM>(
      builder: (context, viewModel, child) => DropdownButton<String>(
        value: viewModel.selectedAudioFile,
        items: AlarmVM.audioFileNames.map((String fileName) {
          return DropdownMenuItem<String>(
            value: fileName,
            child: Text(
              fileName,
              style: const TextStyle(fontSize: kFontSize),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            viewModel.selectedAudioFile = newValue;
          }
        },
      ),
    ));

    return alarmEditionWidgetLst;
  }
}
