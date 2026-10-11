Future<void> load() async {
  print('A: 요청 시작');
  await Future<void>.delayed(const Duration(seconds: 1));
  print('B: 요청 완료');
}

Future<void> main() async {
  // 완료를 나중에 기다리므로 A → C → B 순서입니다.
  final pending = load();
  print('C: 다른 작업');
  await pending;
}
