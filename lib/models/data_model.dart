class DataModel {
  final String id;
  final String content;

  DataModel({required this.id, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
    };
  }

  factory DataModel.fromMap(Map<String, dynamic> map) {
    return DataModel(
      id: map['id'],
      content: map['content'],
    );
  }
}
