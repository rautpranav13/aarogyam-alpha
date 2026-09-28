enum DadiMaSender { user, dadiMa }

class AyurvedicRemedy {
  final String id;
  final String category;
  final String title;
  final String description;
  final List<String> ingredients;
  final String preparation;
  final String precaution;

  const AyurvedicRemedy({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.preparation,
    required this.precaution,
  });

  factory AyurvedicRemedy.fromJson(Map<String, dynamic> json) {
    return AyurvedicRemedy(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      preparation: json['preparation'] as String? ?? '',
      precaution: json['precaution'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'preparation': preparation,
      'precaution': precaution,
    };
  }
}

class DadiMaChatMessage {
  final String id;
  final String text;
  final DadiMaSender sender;
  final DateTime timestamp;
  final String? speechText;
  final bool isEmergency;
  final String? emergencyWarning;
  final List<AyurvedicRemedy> remedies;
  final String actionRequired;

  DadiMaChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.speechText,
    this.isEmergency = false,
    this.emergencyWarning,
    this.remedies = const [],
    this.actionRequired = 'NONE',
  });
}

class DadiMaDailyGuidance {
  final String period;
  final String title;
  final String text;
  final String audioText;
  final String language;

  const DadiMaDailyGuidance({
    required this.period,
    required this.title,
    required this.text,
    required this.audioText,
    required this.language,
  });

  factory DadiMaDailyGuidance.fromJson(Map<String, dynamic> json) {
    return DadiMaDailyGuidance(
      period: json['period'] as String? ?? 'morning',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      audioText: json['audio_text'] as String? ?? '',
      language: json['language'] as String? ?? 'hi',
    );
  }
}
