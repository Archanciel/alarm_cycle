import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/data_viewmodel.dart';
import 'views/data_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataViewModel()..loadData(),
      child: MaterialApp(
        home: DataView(),
      ),
    );
  }
}
