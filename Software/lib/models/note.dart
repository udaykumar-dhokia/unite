class Note {
  String id;
  DateTime date;
  String content;

  Note({
    required this.id,
    required this.date,
    required this.content,
  });

  // Convert a Note to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'content': content,
    };
  }

  // Convert a Firestore document to a Note
  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      date: DateTime.parse(map['date']),
      content: map['content'],
    );
  }
}
