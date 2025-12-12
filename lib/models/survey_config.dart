enum QuestionType {
  radio,
  checkbox,
  text,
  scale,
  number,
  dropdown;

  String get displayName {
    switch (this) {
      case QuestionType.radio:
        return 'Single Choice';
      case QuestionType.checkbox:
        return 'Multiple Choice';
      case QuestionType.text:
        return 'Text';
      case QuestionType.scale:
        return 'Rating Scale';
      case QuestionType.number:
        return 'Number';
      case QuestionType.dropdown:
        return 'Dropdown';
    }
  }

  String toJson() => name;
  static QuestionType fromJson(String json) => values.byName(json);
}

class SurveySection {
  final String id;
  String title;
  String description;
  bool isRequired;
  final List<SurveyQuestion> questions;

  SurveySection({
    required this.id,
    required this.title,
    required this.description,
    required this.isRequired,
    required this.questions,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isRequired': isRequired,
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  factory SurveySection.fromJson(Map<String, dynamic> json) {
    return SurveySection(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isRequired: json['isRequired'],
      questions: (json['questions'] as List)
          .map((q) => SurveyQuestion.fromJson(q))
          .toList(),
    );
  }
}

class SurveyQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final bool isRequired;
  final List<String> options;

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.isRequired,
    required this.options,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'type': type.toJson(),
    'isRequired': isRequired,
    'options': options,
  };

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'],
      question: json['question'],
      type: QuestionType.fromJson(json['type']),
      isRequired: json['isRequired'],
      options: List<String>.from(json['options']),
    );
  }
}
