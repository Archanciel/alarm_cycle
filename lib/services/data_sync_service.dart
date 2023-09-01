import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/data_model.dart';

class DataSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addData(DataModel data) async {
    await _firestore.collection('data').add(data.toMap());
  }

  Stream<List<DataModel>> getDataStream() {
    return _firestore.collection('data').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DataModel.fromMap(doc.data())).toList();
    });
  }
}
