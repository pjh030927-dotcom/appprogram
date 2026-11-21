class ActivityItem {
  final String name;
  final String description;
  final int? maxLength;

  ActivityItem({this.name = '', this.description = '', this.maxLength});

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      maxLength: json['maxLength'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description, 'maxLength': maxLength};
  }
}

class QualificationItem {
  final String type;
  final String grade;
  final String score;
  final String licenseNumber;

  QualificationItem({
    this.type = '',
    this.grade = '',
    this.score = '',
    this.licenseNumber = '',
  });

  factory QualificationItem.fromJson(Map<String, dynamic> json) {
    return QualificationItem(
      type: json['type'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      score: json['score'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'grade': grade,
      'score': score,
      'licenseNumber': licenseNumber,
    };
  }
}

class AwardItem {
  final String title;
  final String organization;
  final String date;
  final String description;
  final int? maxLength;

  AwardItem({
    this.title = '',
    this.organization = '',
    this.date = '',
    this.description = '',
    this.maxLength,
  });

  factory AwardItem.fromJson(Map<String, dynamic> json) {
    return AwardItem(
      title: json['title'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      date: json['date'] as String? ?? '',
      description: json['description'] as String? ?? '',
      maxLength: json['maxLength'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'organization': organization,
      'date': date,
      'description': description,
      'maxLength': maxLength,
    };
  }
}

class CustomSectionItem {
  final String title;
  final String content;
  final int? maxLength;

  CustomSectionItem({this.title = '', this.content = '', this.maxLength});

  factory CustomSectionItem.fromJson(Map<String, dynamic> json) {
    return CustomSectionItem(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      maxLength: json['maxLength'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content, 'maxLength': maxLength};
  }
}

class ResumeModel {
  final String id;
  final String company;
  final DateTime deadline;
  final List<ActivityItem> jobExperiences;
  final List<ActivityItem> activities;
  final List<QualificationItem> languages;
  final List<QualificationItem> certificates;
  final List<AwardItem> awards;
  final String selfIntroduction;
  final int? selfIntroductionMaxLength;
  final String motivation;
  final int? motivationMaxLength;
  final List<CustomSectionItem> customSections;

  ResumeModel({
    String? id,
    required this.company,
    required this.deadline,
    this.jobExperiences = const [],
    this.activities = const [],
    this.languages = const [],
    this.certificates = const [],
    this.awards = const [],
    this.selfIntroduction = '',
    this.selfIntroductionMaxLength,
    this.motivation = '',
    this.motivationMaxLength,
    this.customSections = const [],
  }) : id = (id != null && id.isNotEmpty)
           ? id
           : DateTime.now().microsecondsSinceEpoch.toString();

  factory ResumeModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    final rawId = json['id'] as String?;
    return ResumeModel(
      id: (rawId != null && rawId.isNotEmpty) ? rawId : fallbackId,
      company: json['company'] as String? ?? '',
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : DateTime.now(),
      jobExperiences:
          (json['jobExperiences'] as List<dynamic>?)
              ?.map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activities:
          (json['activities'] as List<dynamic>?)
              ?.map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map(
                (e) => QualificationItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      certificates:
          (json['certificates'] as List<dynamic>?)
              ?.map(
                (e) => QualificationItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      awards:
          (json['awards'] as List<dynamic>?)
              ?.map((e) => AwardItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      selfIntroduction: json['selfIntroduction'] as String? ?? '',
      selfIntroductionMaxLength: json['selfIntroductionMaxLength'] as int?,
      motivation: json['motivation'] as String? ?? '',
      motivationMaxLength: json['motivationMaxLength'] as int?,
      customSections:
          (json['customSections'] as List<dynamic>?)
              ?.map(
                (e) => CustomSectionItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'deadline': deadline.toIso8601String(),
      'jobExperiences': jobExperiences.map((e) => e.toJson()).toList(),
      'activities': activities.map((e) => e.toJson()).toList(),
      'languages': languages.map((e) => e.toJson()).toList(),
      'certificates': certificates.map((e) => e.toJson()).toList(),
      'awards': awards.map((e) => e.toJson()).toList(),
      'selfIntroduction': selfIntroduction,
      'selfIntroductionMaxLength': selfIntroductionMaxLength,
      'motivation': motivation,
      'motivationMaxLength': motivationMaxLength,
      'customSections': customSections.map((e) => e.toJson()).toList(),
    };
  }
}
