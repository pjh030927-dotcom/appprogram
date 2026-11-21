import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/resume_model.dart';
import '../providers/resume_provider.dart';
import '../providers/experience_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _companyController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _calculateDday(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(deadline.year, deadline.month, deadline.day);
    final difference = targetDate.difference(today).inDays;

    if (difference > 0) return 'D-$difference';
    if (difference == 0) return 'D-Day';
    return 'D+${difference.abs()} (마감)';
  }

  void _showAddResumeDialog() {
    _selectedDate = DateTime.now().add(const Duration(days: 7));
    _companyController.clear();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                '새 지원 기업 추가',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      labelText: '지원 기업 및 직무 (예: 삼성전자 DS SW개발)',
                      errorText: errorMessage,
                    ),
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setStateDialog(() => errorMessage = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('서류 마감일: '),
                      TextButton.icon(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setStateDialog(() => _selectedDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(_formatDate(_selectedDate)),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final companyName = _companyController.text.trim();
                    if (companyName.isEmpty) {
                      setStateDialog(() => errorMessage = '빈 공간없이 입력해주세요');
                      return;
                    }
                    final newResume = ResumeModel(
                      company: companyName,
                      deadline: _selectedDate,
                    );
                    context.read<ResumeProvider>().addResume(newResume);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ResumeModel resume) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('자소서 삭제'),
        content: Text('${resume.company} 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<ResumeProvider>().deleteResumeById(resume.id);
              Navigator.pop(ctx);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumeList = context.watch<ResumeProvider>().resumeList;
    final expList = context.watch<ExperienceProvider>().experienceList;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.business_center_rounded, size: 24),
            SizedBox(width: 10),
            Text(
              '커리어핏 AI 자소서 매니저',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('채용 공고 연동 기능은 추후 확장 예정입니다.')),
              );
            },
            icon: const Icon(
              Icons.travel_explore,
              color: Colors.white70,
              size: 18,
            ),
            label: const Text('공고 보기', style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1565C0),
              ),
              onPressed: () => context.push('/specs'),
              icon: const Icon(Icons.assignment_ind_outlined, size: 18),
              label: Text(
                '내 스펙·경험 입력 (${expList.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '나의 지원 및 스펙 현황',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '작성 중인 자소서 ${resumeList.length}건  |  등록된 학력·자격증·경험 ${expList.length}건',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddResumeDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('새 지원 기업 추가'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '지원 기업별 자소서 마감 현황',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: resumeList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.post_add_rounded,
                            size: 56,
                            color: Colors.blue.shade200,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '작성 중인 자소서가 없습니다.\n우측 상단의 [새 지원 기업 추가] 버튼을 눌러 시작해 보세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 360,
                            childAspectRatio: 2.1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: resumeList.length,
                      itemBuilder: (context, index) {
                        final resume = resumeList[index];
                        final dDayString = _calculateDday(resume.deadline);

                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: InkWell(
                            onTap: () => context.push('/resume/${resume.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          resume.company,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFBFDBFE),
                                          ),
                                        ),
                                        child: Text(
                                          dDayString,
                                          style: const TextStyle(
                                            color: Color(0xFF1D4ED8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.schedule,
                                            size: 15,
                                            color: Colors.black45,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '마감일: ${_formatDate(resume.deadline)}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () =>
                                            _confirmDelete(context, resume),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
