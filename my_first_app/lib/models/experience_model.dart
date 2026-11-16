class ExperienceModel {
  final String category; // '학력', '자격증', '대외활동/경험' 구분
  final String title; // 학교명 / 자격증명 / 프로젝트명
  final String subtitle; // 전공 및 학점 / 발급기관 및 급수 / 담당 역할
  final String period; // 재학기간 / 취득일 / 수행기간
  final String content; // 상세 설명 및 성과

  ExperienceModel({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.period,
    required this.content,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      category: json['category'] as String? ?? '대외활동/경험',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      period: json['period'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'subtitle': subtitle,
      'period': period,
      'content': content,
    };
  }
}
