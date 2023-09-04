import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_model.dart';
import '../viewmodels/data_viewmodel.dart';

class DataView extends StatelessWidget {
  const DataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Sync App')),
      body: Consumer<DataViewModel>(
        builder: (context, viewModel, child) {
          return ListView.builder(
            itemCount: viewModel.dataList.length,
            itemBuilder: (context, index) {
              final data = viewModel.dataList[index];
              return ListTile(
                title: Text(data.content),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newData = DataModel(id: '1', content: 'New Data');
          Provider.of<DataViewModel>(context, listen: false).addData(newData);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
