import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/resume_model.dart';
import '../providers/resume_provider.dart';
import '../providers/experience_provider.dart';
import '../utils/file_exporter.dart';

class _ActivityControllers {
  final TextEditingController name;
  final TextEditingController description;
  final TextEditingController maxLength;

  _ActivityControllers({
    required VoidCallback onChanged,
    String name = '',
    String description = '',
    int? maxLength,
  }) : name = TextEditingController(text: name),
       description = TextEditingController(text: description),
       maxLength = TextEditingController(
         text: maxLength != null && maxLength > 0 ? maxLength.toString() : '',
       ) {
    this.name.addListener(onChanged);
    this.description.addListener(onChanged);
    this.maxLength.addListener(onChanged);
  }

  void dispose() {
    name.dispose();
    description.dispose();
    maxLength.dispose();
  }
}

class _QualificationControllers {
  final TextEditingController type;
  final TextEditingController grade;
  final TextEditingController score;
  final TextEditingController licenseNumber;

  _QualificationControllers({
    required VoidCallback onChanged,
    String type = '',
    String grade = '',
    String score = '',
    String licenseNumber = '',
  }) : type = TextEditingController(text: type),
       grade = TextEditingController(text: grade),
       score = TextEditingController(text: score),
       licenseNumber = TextEditingController(text: licenseNumber) {
    this.type.addListener(onChanged);
    this.grade.addListener(onChanged);
    this.score.addListener(onChanged);
    this.licenseNumber.addListener(onChanged);
  }

  void dispose() {
    type.dispose();
    grade.dispose();
    score.dispose();
    licenseNumber.dispose();
  }
}

class _AwardControllers {
  final TextEditingController title;
  final TextEditingController organization;
  final TextEditingController date;
  final TextEditingController description;
  final TextEditingController maxLength;

  _AwardControllers({
    required VoidCallback onChanged,
    String title = '',
    String organization = '',
    String date = '',
    String description = '',
    int? maxLength,
  }) : title = TextEditingController(text: title),
       organization = TextEditingController(text: organization),
       date = TextEditingController(text: date),
       description = TextEditingController(text: description),
       maxLength = TextEditingController(
         text: maxLength != null && maxLength > 0 ? maxLength.toString() : '',
       ) {
    this.title.addListener(onChanged);
    this.organization.addListener(onChanged);
    this.date.addListener(onChanged);
    this.description.addListener(onChanged);
    this.maxLength.addListener(onChanged);
  }

  void dispose() {
    title.dispose();
    organization.dispose();
    date.dispose();
    description.dispose();
    maxLength.dispose();
  }
}

class _CustomSectionControllers {
  final TextEditingController title;
  final TextEditingController content;
  final TextEditingController maxLength;

  _CustomSectionControllers({
    required VoidCallback onChanged,
    String title = '',
    String content = '',
    int? maxLength,
  }) : title = TextEditingController(text: title),
       content = TextEditingController(text: content),
       maxLength = TextEditingController(
         text: maxLength != null && maxLength > 0 ? maxLength.toString() : '',
       ) {
    this.title.addListener(onChanged);
    this.content.addListener(onChanged);
    this.maxLength.addListener(onChanged);
  }

  void dispose() {
    title.dispose();
    content.dispose();
    maxLength.dispose();
  }
}

class ResumeDetailScreen extends StatefulWidget {
  final String resumeId;

  const ResumeDetailScreen({super.key, required this.resumeId});

  @override
  State<ResumeDetailScreen> createState() => _ResumeDetailScreenState();
}

class _ResumeDetailScreenState extends State<ResumeDetailScreen> {
  final List<_ActivityControllers> _jobExpControllers = [];
  final List<_ActivityControllers> _activityControllers = [];
  final List<_QualificationControllers> _languageControllers = [];
  final List<_QualificationControllers> _certControllers = [];
  final List<_AwardControllers> _awardControllers = [];
  final List<_CustomSectionControllers> _customSectionControllers = [];

  late final TextEditingController _selfIntroController;
  late final TextEditingController _selfIntroMaxController;
  late final TextEditingController _motivationController;
  late final TextEditingController _motivationMaxController;

  bool _isFound = true;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  DateTime? _lastSavedAt;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    final resume = context.read<ResumeProvider>().getById(widget.resumeId);

    if (resume == null) {
      _isFound = false;
      _selfIntroController = TextEditingController();
      _selfIntroMaxController = TextEditingController();
      _motivationController = TextEditingController();
      _motivationMaxController = TextEditingController();
      return;
    }

    for (final item in resume.jobExperiences) {
      _jobExpControllers.add(
        _ActivityControllers(
          onChanged: _onFieldChanged,
          name: item.name,
          description: item.description,
          maxLength: item.maxLength,
        ),
      );
    }
    for (final item in resume.activities) {
      _activityControllers.add(
        _ActivityControllers(
          onChanged: _onFieldChanged,
          name: item.name,
          description: item.description,
          maxLength: item.maxLength,
        ),
      );
    }
    for (final item in resume.languages) {
      _languageControllers.add(
        _QualificationControllers(
          onChanged: _onFieldChanged,
          type: item.type,
          grade: item.grade,
          score: item.score,
          licenseNumber: item.licenseNumber,
        ),
      );
    }
    for (final item in resume.certificates) {
      _certControllers.add(
        _QualificationControllers(
          onChanged: _onFieldChanged,
          type: item.type,
          grade: item.grade,
          score: item.score,
          licenseNumber: item.licenseNumber,
        ),
      );
    }
    for (final item in resume.awards) {
      _awardControllers.add(
        _AwardControllers(
          onChanged: _onFieldChanged,
          title: item.title,
          organization: item.organization,
          date: item.date,
          description: item.description,
          maxLength: item.maxLength,
        ),
      );
    }
    for (final item in resume.customSections) {
      _customSectionControllers.add(
        _CustomSectionControllers(
          onChanged: _onFieldChanged,
          title: item.title,
          content: item.content,
          maxLength: item.maxLength,
        ),
      );
    }

    _selfIntroController = TextEditingController(text: resume.selfIntroduction)
      ..addListener(_onFieldChanged);
    _selfIntroMaxController = TextEditingController(
      text:
          resume.selfIntroductionMaxLength != null &&
              resume.selfIntroductionMaxLength! > 0
          ? resume.selfIntroductionMaxLength.toString()
          : '',
    )..addListener(_onFieldChanged);

    _motivationController = TextEditingController(text: resume.motivation)
      ..addListener(_onFieldChanged);
    _motivationMaxController = TextEditingController(
      text:
          resume.motivationMaxLength != null && resume.motivationMaxLength! > 0
          ? resume.motivationMaxLength.toString()
          : '',
    )..addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    for (final c in _jobExpControllers) {
      c.dispose();
    }
    for (final c in _activityControllers) {
      c.dispose();
    }
    for (final c in _languageControllers) {
      c.dispose();
    }
    for (final c in _certControllers) {
      c.dispose();
    }
    for (final c in _awardControllers) {
      c.dispose();
    }
    for (final c in _customSectionControllers) {
      c.dispose();
    }
    _selfIntroController.dispose();
    _selfIntroMaxController.dispose();
    _motivationController.dispose();
    _motivationMaxController.dispose();
    super.dispose();
  }

  // 입력 변경 시 1.5초 디바운스 후 자동 저장 예약
  void _onFieldChanged() {
    if (!_isFound || !mounted) return;
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 1500), () {
      _saveResume(isAutoSave: true);
    });
  }

  int? _parsePositiveInt(String text) {
    final value = int.tryParse(text.trim());
    if (value == null || value <= 0) return null;
    return value;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  ResumeModel? _buildUpdatedModel() {
    final current = context.read<ResumeProvider>().getById(widget.resumeId);
    if (current == null) return null;

    return ResumeModel(
      id: current.id,
      company: current.company,
      deadline: current.deadline,
      jobExperiences: _jobExpControllers
          .map(
            (c) => ActivityItem(
              name: c.name.text.trim(),
              description: c.description.text.trim(),
              maxLength: _parsePositiveInt(c.maxLength.text),
            ),
          )
          .toList(),
      activities: _activityControllers
          .map(
            (c) => ActivityItem(
              name: c.name.text.trim(),
              description: c.description.text.trim(),
              maxLength: _parsePositiveInt(c.maxLength.text),
            ),
          )
          .toList(),
      languages: _languageControllers
          .map(
            (c) => QualificationItem(
              type: c.type.text.trim(),
              grade: c.grade.text.trim(),
              score: c.score.text.trim(),
              licenseNumber: c.licenseNumber.text.trim(),
            ),
          )
          .toList(),
      certificates: _certControllers
          .map(
            (c) => QualificationItem(
              type: c.type.text.trim(),
              grade: c.grade.text.trim(),
              score: c.score.text.trim(),
              licenseNumber: c.licenseNumber.text.trim(),
            ),
          )
          .toList(),
      awards: _awardControllers
          .map(
            (c) => AwardItem(
              title: c.title.text.trim(),
              organization: c.organization.text.trim(),
              date: c.date.text.trim(),
              description: c.description.text.trim(),
              maxLength: _parsePositiveInt(c.maxLength.text),
            ),
          )
          .toList(),
      selfIntroduction: _selfIntroController.text,
      selfIntroductionMaxLength: _parsePositiveInt(
        _selfIntroMaxController.text,
      ),
      motivation: _motivationController.text,
      motivationMaxLength: _parsePositiveInt(_motivationMaxController.text),
      customSections: _customSectionControllers
          .map(
            (c) => CustomSectionItem(
              title: c.title.text.trim(),
              content: c.content.text,
              maxLength: _parsePositiveInt(c.maxLength.text),
            ),
          )
          .toList(),
    );
  }

  Future<void> _saveResume({bool isAutoSave = false}) async {
    _autoSaveTimer?.cancel();
    final updated = _buildUpdatedModel();
    if (updated == null) return;

    if (mounted) {
      setState(() => _isSaving = true);
    }

    await context.read<ResumeProvider>().updateResumeById(
      widget.resumeId,
      updated,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _hasUnsavedChanges = false;
      _lastSavedAt = DateTime.now();
    });

    if (!isAutoSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('자소서 내용이 저장되었습니다.'),
          backgroundColor: Color(0xFF1565C0),
        ),
      );
    }
  }

  // 미저장 이탈 방지 확인 다이얼로그
  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Future<void> _handleExitAttempt() async {
    if (!_hasUnsavedChanges) {
      _navigateBack();
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '저장되지 않은 변경 사항',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('아직 자동 저장이 완료되지 않은 내용이 있습니다.\n저장하고 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('계속 작성'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: const Text(
              '저장 안 하고 나가기',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: const Text('저장 후 나가기'),
          ),
        ],
      ),
    );

    if (!mounted || result == null || result == 'cancel') return;

    if (result == 'save') {
      await _saveResume(isAutoSave: true);
    } else if (result == 'discard') {
      _autoSaveTimer?.cancel();
      setState(() => _hasUnsavedChanges = false);
    }

    // PopScope의 canPop이 true로 갱신된 직후 화면 이탈 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _navigateBack();
    });
  }

  // 문항별 원클릭 클립보드 복사
  Future<void> _copyText(String label, String text) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('복사할 [$label] 내용이 없습니다.')));
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('[$label] 내용이 클립보드에 복사되었습니다.'),
        backgroundColor: const Color(0xFF1565C0),
        duration: const Duration(seconds: 120),
      ),
    );
  }

  // 전체 자소서 .txt 파일 내보내기
  Future<void> _exportResumeToTxt() async {
    if (_hasUnsavedChanges) {
      await _saveResume(isAutoSave: true);
    }
    final resume = _buildUpdatedModel();
    if (resume == null) return;

    final buffer = StringBuffer();
    buffer.writeln('==================================================');
    buffer.writeln('지원 기업: ${resume.company}');
    buffer.writeln('서류 마감일: ${_formatDate(resume.deadline)}');
    buffer.writeln(
      '내보내기 시각: ${_formatDate(DateTime.now())} ${_formatTime(DateTime.now())}',
    );
    buffer.writeln('==================================================\n');

    void writeActivityGroup(String header, List<ActivityItem> items) {
      buffer.writeln('[$header]');
      if (items.isEmpty) {
        buffer.writeln('- 등록된 항목 없음\n');
        return;
      }
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        buffer.writeln('${i + 1}. 활동명: ${item.name}');
        buffer.writeln(
          '   상세설명 (${item.description.length}자): ${item.description}\n',
        );
      }
    }

    void writeQualificationGroup(String header, List<QualificationItem> items) {
      buffer.writeln('[$header]');
      if (items.isEmpty) {
        buffer.writeln('- 등록된 항목 없음\n');
        return;
      }
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        buffer.writeln(
          '${i + 1}. 종류: ${item.type} | 등급: ${item.grade} | 점수: ${item.score} | 자격번호: ${item.licenseNumber}',
        );
      }
      buffer.writeln();
    }

    writeActivityGroup('1. 직무 관련 경험', resume.jobExperiences);
    writeActivityGroup('2. 대내외 활동', resume.activities);
    writeQualificationGroup('3. 어학사항', resume.languages);
    writeQualificationGroup('4. 자격/면허사항', resume.certificates);

    buffer.writeln('[5. 직무 관련 수상사항]');
    if (resume.awards.isEmpty) {
      buffer.writeln('- 등록된 항목 없음\n');
    } else {
      for (int i = 0; i < resume.awards.length; i++) {
        final award = resume.awards[i];
        buffer.writeln(
          '${i + 1}. 수상내용: ${award.title} | 시상단체: ${award.organization} | 수상일자: ${award.date}',
        );
        buffer.writeln(
          '   상세설명 (${award.description.length}자): ${award.description}\n',
        );
      }
    }

    buffer.writeln('[6. 자기소개 (공백 포함 ${resume.selfIntroduction.length}자)]');
    buffer.writeln(
      resume.selfIntroduction.isEmpty ? '(미작성)' : resume.selfIntroduction,
    );
    buffer.writeln();

    buffer.writeln('[7. 지원동기 (공백 포함 ${resume.motivation.length}자)]');
    buffer.writeln(resume.motivation.isEmpty ? '(미작성)' : resume.motivation);
    buffer.writeln();

    if (resume.customSections.isNotEmpty) {
      buffer.writeln('[8. 추가 문항]');
      for (int i = 0; i < resume.customSections.length; i++) {
        final sec = resume.customSections[i];
        final title = sec.title.isEmpty ? '추가 문항 #${i + 1}' : sec.title;
        buffer.writeln('${i + 1}. $title (공백 포함 ${sec.content.length}자)');
        buffer.writeln(sec.content.isEmpty ? '(미작성)' : sec.content);
        buffer.writeln();
      }
    }

    final safeCompany = resume.company.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final fileName = '${safeCompany}_자소서.txt';
    final content = buffer.toString();

    final downloaded = await exportTextFile(
      fileName: fileName,
      content: content,
    );

    if (!mounted) return;
    if (downloaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName 파일이 다운로드되었습니다.'),
          backgroundColor: const Color(0xFF1565C0),
        ),
      );
    } else {
      // 비웹 환경에서는 전체 텍스트를 클립보드로 복사
      await Clipboard.setData(ClipboardData(text: content));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 환경에서는 전체 자소서 텍스트를 클립보드에 복사했습니다.')),
      );
    }
  }

  Future<void> _selectAwardDate(TextEditingController dateController) async {
    DateTime initialDate = DateTime.now();
    if (dateController.text.isNotEmpty) {
      final parsed = DateTime.tryParse(dateController.text);
      if (parsed != null) initialDate = parsed;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        dateController.text = _formatDate(picked);
      });
    }
  }

  void _showImportFromExperienceDialog() {
    final expList = context.read<ExperienceProvider>().experienceList;

    if (expList.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('내 스펙 보관함 비어 있음'),
          content: const Text(
            '등록된 스펙·경험 데이터가 없습니다.\n먼저 홈 화면의 [내 스펙·경험 입력]에서 항목을 등록해 주세요.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    final Set<int> selectedIndices = {};
    final Map<int, String> targetSectionMap = {};
    const targetOptions = ['직무 관련 경험', '대내외 활동', '어학사항', '자격/면허사항'];

    for (int i = 0; i < expList.length; i++) {
      final category = expList[i].category;
      if (category == '자격증') {
        targetSectionMap[i] = '자격/면허사항';
      } else if (category == '학력') {
        targetSectionMap[i] = '대내외 활동';
      } else {
        targetSectionMap[i] = '직무 관련 경험';
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                '내 스펙·경험 보관함에서 불러오기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 580,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '불러올 항목을 선택하고 어느 자소서 영역에 넣을지 지정해 주세요.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: expList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final exp = expList[index];
                            final isSelected = selectedIndices.contains(index);
                            final currentTarget =
                                targetSectionMap[index] ?? '직무 관련 경험';

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEFF6FF)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1565C0)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: const Color(0xFF1565C0),
                                    onChanged: (checked) {
                                      setStateDialog(() {
                                        if (checked == true) {
                                          selectedIndices.add(index);
                                        } else {
                                          selectedIndices.remove(index);
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDBEAFE),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                exp.category,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1565C0),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                exp.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (exp.subtitle.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            exp.subtitle,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Text(
                                              '반영 위치: ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            DropdownButton<String>(
                                              value: currentTarget,
                                              isDense: true,
                                              underline: const SizedBox(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1565C0),
                                              ),
                                              items: targetOptions
                                                  .map(
                                                    (opt) => DropdownMenuItem(
                                                      value: opt,
                                                      child: Text(opt),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setStateDialog(() {
                                                    targetSectionMap[index] =
                                                        val;
                                                    selectedIndices.add(index);
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: selectedIndices.isEmpty
                      ? null
                      : () {
                          final sorted = selectedIndices.toList()..sort();
                          setState(() {
                            for (final i in sorted) {
                              final exp = expList[i];
                              final target = targetSectionMap[i] ?? '직무 관련 경험';

                              final descParts = <String>[
                                if (exp.subtitle.isNotEmpty) exp.subtitle,
                                if (exp.period.isNotEmpty)
                                  '기간/일자: ${exp.period}',
                                if (exp.content.isNotEmpty) exp.content,
                              ];
                              final combinedDesc = descParts.join('\n');

                              if (target == '직무 관련 경험') {
                                _jobExpControllers.add(
                                  _ActivityControllers(
                                    onChanged: _onFieldChanged,
                                    name: exp.title,
                                    description: combinedDesc,
                                  ),
                                );
                              } else if (target == '대내외 활동') {
                                _activityControllers.add(
                                  _ActivityControllers(
                                    onChanged: _onFieldChanged,
                                    name: exp.title,
                                    description: combinedDesc,
                                  ),
                                );
                              } else if (target == '어학사항') {
                                _languageControllers.add(
                                  _QualificationControllers(
                                    onChanged: _onFieldChanged,
                                    type: exp.title,
                                    grade: exp.subtitle,
                                  ),
                                );
                              } else if (target == '자격/면허사항') {
                                _certControllers.add(
                                  _QualificationControllers(
                                    onChanged: _onFieldChanged,
                                    type: exp.title,
                                    grade: exp.subtitle,
                                  ),
                                );
                              }
                            }
                          });
                          _onFieldChanged();

                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${sorted.length}건의 스펙을 불러왔습니다. 잠시 후 자동 저장됩니다.',
                              ),
                              backgroundColor: const Color(0xFF1565C0),
                            ),
                          );
                        },
                  child: Text('불러오기 (${selectedIndices.length}건)'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSaveStatusBadge() {
    String label;
    IconData icon;
    if (_isSaving) {
      label = '저장 중...';
      icon = Icons.sync;
    } else if (_hasUnsavedChanges) {
      label = '작성 중 (자동 저장 대기)';
      icon = Icons.edit_note;
    } else if (_lastSavedAt != null) {
      label = '자동 저장됨 (${_formatTime(_lastSavedAt!)})';
      icon = Icons.cloud_done_outlined;
    } else {
      label = '자동 저장 활성';
      icon = Icons.cloud_done_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton({
    required String label,
    required String Function() getText,
  }) {
    return OutlinedButton.icon(
      onPressed: () => _copyText(label, getText()),
      icon: const Icon(Icons.content_copy, size: 15),
      label: const Text('복사', style: TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1565C0),
        side: const BorderSide(color: Color(0xFFBFDBFE)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildCharCounterWithLimit({
    required TextEditingController contentController,
    required TextEditingController maxLengthController,
    required String copyLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: maxLengthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: '목표 글자 수',
                      hintText: '예: 500',
                      suffixText: '자',
                      isDense: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildCopyButton(
                  label: copyLabel,
                  getText: () => contentController.text,
                ),
              ],
            ),
            AnimatedBuilder(
              animation: Listenable.merge([
                contentController,
                maxLengthController,
              ]),
              builder: (context, _) {
                final text = contentController.text;
                final withSpaces = text.length;
                final withoutSpaces = text
                    .replaceAll(RegExp(r'\s+'), '')
                    .length;
                final limit = _parsePositiveInt(maxLengthController.text);
                final isOver = limit != null && withSpaces > limit;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isOver) ...[
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      limit != null
                          ? '공백 포함 $withSpaces / $limit자${isOver ? ' (${withSpaces - limit}자 초과)' : ''}  |  공백 제외 $withoutSpaces자'
                          : '공백 포함 $withSpaces자  |  공백 제외 $withoutSpaces자',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOver ? Colors.red : const Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 18, color: Color(0xFF1565C0)),
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: const Color(0xFFEFF6FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFBFDBFE)),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection({
    required String title,
    required List<_ActivityControllers> list,
    required String emptyMessage,
  }) {
    return _buildSectionCard(
      title: title,
      trailing: _buildAddButton(
        label: '활동 추가',
        onPressed: () {
          setState(() {
            list.add(_ActivityControllers(onChanged: _onFieldChanged));
          });
          _onFieldChanged();
        },
      ),
      child: list.isEmpty
          ? Text(
              emptyMessage,
              style: const TextStyle(color: Colors.black45, fontSize: 13),
            )
          : Column(
              children: List.generate(list.length, (index) {
                final item = list[index];
                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == list.length - 1 ? 0 : 16,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$title #${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: '항목 삭제',
                            onPressed: () {
                              setState(() {
                                final removed = list.removeAt(index);
                                removed.dispose();
                              });
                              _onFieldChanged();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: item.name,
                        decoration: const InputDecoration(
                          labelText: '활동명',
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: item.description,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: '활동 상세설명',
                          alignLabelWithHint: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      _buildCharCounterWithLimit(
                        contentController: item.description,
                        maxLengthController: item.maxLength,
                        copyLabel: '$title #${index + 1}',
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildQualificationSection({
    required String title,
    required String addButtonLabel,
    required List<_QualificationControllers> list,
    required String emptyMessage,
  }) {
    return _buildSectionCard(
      title: title,
      trailing: _buildAddButton(
        label: addButtonLabel,
        onPressed: () {
          setState(() {
            list.add(_QualificationControllers(onChanged: _onFieldChanged));
          });
          _onFieldChanged();
        },
      ),
      child: list.isEmpty
          ? Text(
              emptyMessage,
              style: const TextStyle(color: Colors.black45, fontSize: 13),
            )
          : Column(
              children: List.generate(list.length, (index) {
                final item = list[index];
                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == list.length - 1 ? 0 : 16,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$title #${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildCopyButton(
                                label: '$title #${index + 1}',
                                getText: () => [
                                  if (item.type.text.trim().isNotEmpty)
                                    '종류: ${item.type.text.trim()}',
                                  if (item.grade.text.trim().isNotEmpty)
                                    '등급: ${item.grade.text.trim()}',
                                  if (item.score.text.trim().isNotEmpty)
                                    '점수: ${item.score.text.trim()}',
                                  if (item.licenseNumber.text.trim().isNotEmpty)
                                    '자격번호: ${item.licenseNumber.text.trim()}',
                                ].join(' / '),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: '항목 삭제',
                                onPressed: () {
                                  setState(() {
                                    final removed = list.removeAt(index);
                                    removed.dispose();
                                  });
                                  _onFieldChanged();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: item.type,
                              decoration: const InputDecoration(
                                labelText: '종류',
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: item.grade,
                              decoration: const InputDecoration(
                                labelText: '등급',
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: item.score,
                              decoration: const InputDecoration(
                                labelText: '점수',
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: item.licenseNumber,
                              decoration: const InputDecoration(
                                labelText: '자격번호',
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildAwardSection() {
    return _buildSectionCard(
      title: '직무 관련 수상사항',
      trailing: _buildAddButton(
        label: '수상 추가',
        onPressed: () {
          setState(() {
            _awardControllers.add(
              _AwardControllers(onChanged: _onFieldChanged),
            );
          });
          _onFieldChanged();
        },
      ),
      child: _awardControllers.isEmpty
          ? const Text(
              '등록된 수상사항이 없습니다. 우측 [+ 수상 추가] 버튼을 눌러 입력해 주세요.',
              style: TextStyle(color: Colors.black45, fontSize: 13),
            )
          : Column(
              children: List.generate(_awardControllers.length, (index) {
                final item = _awardControllers[index];
                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == _awardControllers.length - 1 ? 0 : 16,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '수상사항 #${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: '항목 삭제',
                            onPressed: () {
                              setState(() {
                                final removed = _awardControllers.removeAt(
                                  index,
                                );
                                removed.dispose();
                              });
                              _onFieldChanged();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: item.title,
                        decoration: const InputDecoration(
                          labelText: '수상내용',
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: item.organization,
                              decoration: const InputDecoration(
                                labelText: '시상단체',
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: item.date,
                              onTap: () => _selectAwardDate(item.date),
                              decoration: InputDecoration(
                                labelText: '수상일자',
                                fillColor: Colors.white,
                                prefixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.calendar_month_outlined,
                                    color: Color(0xFF1565C0),
                                  ),
                                  tooltip: '수상일자 선택',
                                  onPressed: () => _selectAwardDate(item.date),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: item.description,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: '수상내용 상세설명',
                          alignLabelWithHint: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      _buildCharCounterWithLimit(
                        contentController: item.description,
                        maxLengthController: item.maxLength,
                        copyLabel: '수상사항 #${index + 1}',
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildCustomSectionsArea() {
    return _buildSectionCard(
      title: '추가 문항 (직접 작성)',
      subtitle: '기업별 특수 문항(예: 입사 후 포부, 문제 해결 경험 등)을 자유롭게 추가하세요.',
      trailing: _buildAddButton(
        label: '문항 추가',
        onPressed: () {
          setState(() {
            _customSectionControllers.add(
              _CustomSectionControllers(onChanged: _onFieldChanged),
            );
          });
          _onFieldChanged();
        },
      ),
      child: _customSectionControllers.isEmpty
          ? const Text(
              '추가된 문항이 없습니다. 우측 [+ 문항 추가] 버튼을 눌러 새 문항을 만들어 보세요.',
              style: TextStyle(color: Colors.black45, fontSize: 13),
            )
          : Column(
              children: List.generate(_customSectionControllers.length, (
                index,
              ) {
                final item = _customSectionControllers[index];
                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == _customSectionControllers.length - 1
                        ? 0
                        : 16,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '추가 문항 #${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: '문항 삭제',
                            onPressed: () {
                              setState(() {
                                final removed = _customSectionControllers
                                    .removeAt(index);
                                removed.dispose();
                              });
                              _onFieldChanged();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: item.title,
                        decoration: const InputDecoration(
                          labelText: '문항 제목 (예: 입사 후 포부)',
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: item.content,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: '답변 내용',
                          alignLabelWithHint: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      _buildCharCounterWithLimit(
                        contentController: item.content,
                        maxLengthController: item.maxLength,
                        copyLabel: item.title.text.trim().isEmpty
                            ? '추가 문항 #${index + 1}'
                            : item.title.text.trim(),
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resume = context.watch<ResumeProvider>().getById(widget.resumeId);
    if (!_isFound || resume == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('자소서 없음')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('해당 자소서를 찾을 수 없습니다.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('대시보드로 돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    final expCount = context.watch<ExperienceProvider>().experienceList.length;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleExitAttempt();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: '대시보드로 돌아가기',
            onPressed: _handleExitAttempt,
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  '${resume.company} 자소서',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              _buildSaveStatusBadge(),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: _showImportFromExperienceDialog,
              icon: const Icon(
                Icons.folder_copy_outlined,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                '스펙 불러오기 ($expCount)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              onPressed: _exportResumeToTxt,
              icon: const Icon(
                Icons.download_outlined,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'TXT 내보내기',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1565C0),
                ),
                onPressed: () => _saveResume(isAutoSave: false),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text(
                  '저장하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActivitySection(
                    title: '직무 관련 경험',
                    list: _jobExpControllers,
                    emptyMessage: '등록된 직무 관련 경험이 없습니다. 우측 [+ 활동 추가] 또는 상단 [스펙 불러오기]를 이용해 주세요.',
                  ),
                  _buildActivitySection(
                    title: '대내외 활동',
                    list: _activityControllers,
                    emptyMessage:
                        '등록된 대내외 활동이 없습니다. 우측 [+ 활동 추가] 버튼을 눌러 입력해 주세요.',
                  ),
                  _buildQualificationSection(
                    title: '어학사항',
                    addButtonLabel: '어학 추가',
                    list: _languageControllers,
                    emptyMessage:
                        '등록된 어학사항이 없습니다. 우측 [+ 어학 추가] 버튼을 눌러 입력해 주세요.',
                  ),
                  _buildQualificationSection(
                    title: '자격/면허사항',
                    addButtonLabel: '자격/면허 추가',
                    list: _certControllers,
                    emptyMessage: '등록된 자격/면허사항이 없습니다. 우측 [+ 자격/면허 추가] 또는 상단 [스펙 불러오기]를 이용해 주세요.',
                  ),
                  _buildAwardSection(),
                  _buildSectionCard(
                    title: '자기소개',
                    subtitle: '대인관계, 장단점, 성장과정 등을 자유롭게 작성해 주세요.',
                    child: Column(
                      children: [
                        TextField(
                          controller: _selfIntroController,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            hintText: '자기소개 내용을 입력해 주세요.',
                            alignLabelWithHint: true,
                          ),
                        ),
                        _buildCharCounterWithLimit(
                          contentController: _selfIntroController,
                          maxLengthController: _selfIntroMaxController,
                          copyLabel: '자기소개',
                        ),
                      ],
                    ),
                  ),
                  _buildSectionCard(
                    title: '지원동기',
                    subtitle: '해당 기업과 직무에 지원하게 된 동기를 작성해 주세요.',
                    child: Column(
                      children: [
                        TextField(
                          controller: _motivationController,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            hintText: '지원동기 내용을 입력해 주세요.',
                            alignLabelWithHint: true,
                          ),
                        ),
                        _buildCharCounterWithLimit(
                          contentController: _motivationController,
                          maxLengthController: _motivationMaxController,
                          copyLabel: '지원동기',
                        ),
                      ],
                    ),
                  ),
                  _buildCustomSectionsArea(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
