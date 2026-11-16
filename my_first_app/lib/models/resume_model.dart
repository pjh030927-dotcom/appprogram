class ResumeModel {
  final String company;
  final DateTime deadline;

  ResumeModel({required this.company, required this.deadline});

  // JSON 데이터를 객체로 변환 (역직렬화)
  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      company: json['company'] as String? ?? '',
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : DateTime.now(),
    );
  }

  // 객체를 JSON 데이터로 변환 (직렬화)
  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'deadline': deadline.toIso8601String(), // 날짜를 문자열로 안전하게 저장
    };
  }
}
