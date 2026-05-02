class Fact {
  final int id;
  final String question;
  final String answer;
  final String explanation;
  final int? categoryId;

  Fact({
    required this.id,
    required this.question,
    required this.answer,
    required this.explanation,
    this.categoryId,
  });

  factory Fact.fromJson(Map<String, dynamic> json) {
    return Fact(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      explanation: json['explanation'],
      categoryId: json['category_id'],
    );
  }
}
