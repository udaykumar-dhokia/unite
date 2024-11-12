class Note {
  String id;
  String date;
  String content;
  String title;

  Note({
    required this.id,
    required this.date,
    required this.content,
    required this.title,
  });

  // Convert a Note to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'content': content,
      'title': title,
    };
  }

  // Convert a Firestore document to a Note
  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      title: map['title'],
      date: map['date'],
      content: map['content'],
    );
  }
}
