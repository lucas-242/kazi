/// One line of a release announcement: a short headline plus what changed.
class WhatsNewEntry {
  const WhatsNewEntry({required this.title, required this.description});

  factory WhatsNewEntry.fromMap(Map<String, dynamic> map) => WhatsNewEntry(
    title: map['title'] as String? ?? '',
    description: map['description'] as String? ?? '',
  );

  final String title;
  final String description;
}
