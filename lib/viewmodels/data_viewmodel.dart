import 'package:flutter/material.dart';
import '../models/data_model.dart';
import '../services/data_sync_service.dart';

class DataViewModel extends ChangeNotifier {
  final DataSyncService _dataSyncService = DataSyncService();

  List<DataModel> _dataList = [];

  List<DataModel> get dataList => _dataList;

  void loadData() {
    _dataSyncService.getDataStream().listen((newData) {
      _dataList = newData;
      notifyListeners();
    });
  }

  void addData(DataModel data) {
    _dataSyncService.addData(data);
  }
}
