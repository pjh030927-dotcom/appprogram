import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/experience_model.dart';
import '../providers/experience_provider.dart';

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  String _selectedCategory = '학력'; // 기본 선택 양식: 학력
  String _filterCategory = '전체';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _periodController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 날짜를 YYYY-MM-DD 형식으로 변환하는 함수
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // 달력 아이콘 클릭 시 DatePicker 팝업을 띄우는 함수
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _periodController.text = _formatDate(picked);
      });
    }
  }

  void _clearForm() {
    _titleController.clear();
    _subtitleController.clear();
    _periodController.clear();
    _contentController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _errorMessage = null;
    });
  }

  void _saveSpec() {
    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();
    final period = _periodController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = '필수 항목(명칭)을 입력해주세요.';
      });
      return;
    }

    final newSpec = ExperienceModel(
      category: _selectedCategory,
      title: title,
      subtitle: subtitle,
      period: period,
      content: content,
    );

    context.read<ExperienceProvider>().addExperience(newSpec);
    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('[$_selectedCategory] 항목이 내 스펙 보관함에 저장되었습니다.'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  // 선택된 카테고리에 따라 양식 라벨을 다르게 제공
  Map<String, String> _getFormLabels() {
    switch (_selectedCategory) {
      case '학력':
        return {
          'title': '학교명 (예: 신구대학교)',
          'subtitle': '전공 및 학점 (예: 컴퓨터소프트웨어과 / 4.1/4.5)',
          'period': '졸업(예정)일 선택 (달력 클릭)',
          'content': '주요 이수 과목 및 학업 성취 (선택 사항)',
        };
      case '자격증':
        return {
          'title': '자격증 / 어학 시험명 (예: SQLD, 정보처리기사)',
          'subtitle': '발급 기관 / 점수·급수 (예: 한국데이터산업진흥원 / 합격)',
          'period': '취득일 선택 (달력 클릭)',
          'content': '관련 역량 메모 (예: 데이터베이스 모델링 및 SQL 쿼리 최적화 역량)',
        };
      default: // 직무 경험
        return {
          'title': '경험 / 프로젝트명 (예: 캡스톤 팀 프로젝트)',
          'subtitle': '소속 및 담당 역할 (예: 팀 프로젝트 / 백엔드 및 DB 설계)',
          'period': '수행 기준일 선택 (달력 클릭)',
          'content': '상황(S) - 과제(T) - 행동(A) - 결과(R) 중심으로 상세 경험 작성',
        };
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '학력':
        return Icons.school_outlined;
      case '자격증':
        return Icons.verified_outlined;
      default:
        return Icons.work_outline;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '학력':
        return const Color(0xFF1565C0);
      case '자격증':
        return const Color(0xFF00838F);
      default:
        return const Color(0xFF283593);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExperienceProvider>();
    final filteredList = provider.getByCategory(_filterCategory);
    final labels = _getFormLabels();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내 기본 스펙 & 경험 정리',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 안내 배너
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI 맞춤 자소서 수정을 위한 기초 스펙 데이터',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '학력, 자격증, 직무 경험을 한 번만 등록해 두면 기업별 인재상에 맞춰 자소서 문장을 자동으로 다듬어 줍니다.',
                              style: TextStyle(
                                color: Color(0xFFE3F2FD),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 1. 스펙 입력 양식 카드
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '새 스펙 / 경험 등록 양식',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 양식 카테고리 선택 버튼 (학력 / 자격증 / 직무 경험)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ['학력', '자격증', '직무 경험'].map((category) {
                            final isSelected = _selectedCategory == category;
                            return ChoiceChip(
                              avatar: Icon(
                                _getCategoryIcon(category),
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1565C0),
                              ),
                              label: Text(category),
                              selected: isSelected,
                              selectedColor: const Color(0xFF1565C0),
                              backgroundColor: const Color(0xFFEFF6FF),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1E3A8A),
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category;
                                  _errorMessage = null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // 양식 입력 필드들
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: labels['title'],
                            errorText: _errorMessage,
                            prefixIcon: Icon(
                              _getCategoryIcon(_selectedCategory),
                            ),
                          ),
                          onChanged: (_) {
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _subtitleController,
                                decoration: InputDecoration(
                                  labelText: labels['subtitle'],
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _periodController,
                                onTap: _selectDate, // 칸 클릭 시 달력 팝업 호출
                                decoration: InputDecoration(
                                  labelText: labels['period'],
                                  prefixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.calendar_month_outlined,
                                      color: Color(0xFF1565C0),
                                    ),
                                    tooltip: '날짜 선택',
                                    onPressed:
                                        _selectDate, // 달력 아이콘 클릭 시 달력 팝업 호출
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _contentController,
                          maxLines: _selectedCategory == '직무 경험' ? 4 : 2,
                          decoration: InputDecoration(
                            labelText: labels['content'],
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _clearForm,
                              child: const Text('초기화'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _saveSpec,
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text('$_selectedCategory 저장하기'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 2. 저장된 내 스펙 목록 헤더 및 필터
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '저장된 내 스펙 보관함 (${filteredList.length}건)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: ['전체', '학력', '자격증', '직무 경험'].map((filter) {
                        final isSelected = _filterCategory == filter;
                        return FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: const Color(0xFFDBEAFE),
                          checkmarkColor: const Color(0xFF1565C0),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF1565C0)
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setState(() => _filterCategory = filter);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. 저장된 스펙 카드 리스트
                if (filteredList.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.folder_open, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          '아직 등록된 스펙이 없습니다.\n위 양식에서 학력, 자격증, 직무 경험을 입력하고 저장해 보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final badgeColor = _getCategoryColor(item.category);

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getCategoryIcon(item.category),
                                          size: 14,
                                          color: badgeColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.category,
                                          style: TextStyle(
                                            color: badgeColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (item.period.isNotEmpty)
                                    Text(
                                      item.period,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<ExperienceProvider>()
                                          .deleteExperience(item);
                                    },
                                  ),
                                ],
                              ),
                              if (item.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              if (item.content.isNotEmpty) ...[
                                const Divider(height: 20),
                                Text(
                                  item.content,
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
