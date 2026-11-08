import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _resumeList = [];

  final TextEditingController _companyController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

  // 날짜를 YYYY-MM-DD 형식으로 변환하는 함수
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // 남은 마감 일시(D-day) 계산 함수
  String _calculateDday(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(deadline.year, deadline.month, deadline.day);
    final difference = targetDate.difference(today).inDays;

    if (difference > 0) return 'D-$difference';
    if (difference == 0) return 'D-Day';
    return 'D+${difference.abs()} (마감됨)';
  }

  // 새 자소서 추가 다이얼로그 (10주차 핵심 사용자 행동)
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
              title: const Text('새 지원 기업 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      labelText: '지원 기업명 (예: 네이버)',
                      errorText:
                          errorMessage, // [수정 반영 3 - AC2] 빈 값 입력 시 에러 문구 표시
                    ),
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setStateDialog(() {
                          errorMessage = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('제출 마감일: '),
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
                            setStateDialog(() {
                              _selectedDate = picked;
                            });
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

                    // [수정 반영 3 - AC2] 공백 상태로 등록 시도 시 차단 및 안내 문구 출력
                    if (companyName.isEmpty) {
                      setStateDialog(() {
                        errorMessage = '빈 공간없이 입력해주세요';
                      });
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('빈 공간없이 입력해주세요')),
                      );
                      return;
                    }

                    // 정상 입력 시 메모리 리스트에 추가하고 화면 갱신
                    setState(() {
                      _resumeList.add({
                        'company': companyName,
                        'deadline': _selectedDate,
                      });
                    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자소서 대시보드'),
        actions: [
          // 추후 확장 기능: 공고 보기 (UI 버튼만 배치)
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('공고 보기 기능은 준비 중입니다.')),
              );
            },
            icon: const Icon(Icons.search),
            label: const Text('공고 보기 (준비 중)'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          const SizedBox(width: 12),
          // 필수 기능 진입 버튼: 내 기본 경험 정리하기
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('내 기본 경험 정리하기 화면은 다음 주차에 연결됩니다.')),
              );
            },
            icon: const Icon(Icons.edit_document),
            label: const Text('내 기본 경험 정리하기'),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '작성 중인 자소서 목록',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  onPressed: _showAddResumeDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('새 자소서 추가'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // [AC3 반영] 빈 상태 안내 문구 및 자소서 카드 그리드 표시
            Expanded(
              child: _resumeList.isEmpty
                  ? const Center(
                      child: Text('작성 중인 자소서가 없습니다. 새 자소서를 추가해 주세요.'),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 350,
                            childAspectRatio: 2.3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _resumeList.length,
                      itemBuilder: (context, index) {
                        final resume = _resumeList[index];
                        // [수정 반영 2] Null 안전성 보장 (String? -> String 변환 및 기본값 처리)
                        final companyName =
                            (resume['company'] as String?) ?? '';
                        final deadline =
                            (resume['deadline'] as DateTime?) ?? DateTime.now();
                        final dDayString = _calculateDday(deadline);

                        return Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        companyName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x1AFF5252),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        dDayString,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  '마감일: ${_formatDate(deadline)}',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
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
