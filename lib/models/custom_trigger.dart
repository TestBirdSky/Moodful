class CustomTrigger {
  const CustomTrigger({
    required this.id,
    required this.name,
    this.previousNames = const [],
  });

  final String id;
  final String name;
  final List<String> previousNames;

  List<String> get allNames => [name, ...previousNames];

  CustomTrigger rename(String newName) {
    if (newName == name) {
      return this;
    }

    return CustomTrigger(
      id: id,
      name: newName,
      previousNames: {
        name,
        ...previousNames,
      }.where((item) => item != newName).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'previousNames': previousNames};
  }

  factory CustomTrigger.fromJson(Map<String, dynamic> json) {
    return CustomTrigger(
      id: json['id'] as String,
      name: json['name'] as String,
      previousNames: (json['previousNames'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}

abstract final class TriggerDefaults {
  static const names = [
    'Sleep',
    'Work',
    'Family',
    'Weather',
    'Health',
    'Money',
  ];
}
