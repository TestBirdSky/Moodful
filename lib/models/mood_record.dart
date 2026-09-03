class MoodRecord {
  const MoodRecord({
    required this.dateKey,
    required this.moodIndex,
    required this.energy,
    required this.triggers,
    required this.context,
  });

  final String dateKey;
  final int moodIndex;
  final String? energy;
  final List<String> triggers;
  final String context;

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'moodIndex': moodIndex,
      'energy': energy,
      'triggers': triggers,
      'context': context,
    };
  }

  factory MoodRecord.fromJson(Map<String, dynamic> json) {
    return MoodRecord(
      dateKey: json['dateKey'] as String,
      moodIndex: json['moodIndex'] as int,
      energy: json['energy'] as String?,
      triggers: (json['triggers'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      context: json['context'] as String? ?? '',
    );
  }

  static String dateKeyFor(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
