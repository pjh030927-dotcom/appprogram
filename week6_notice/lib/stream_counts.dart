Stream<int> noticeCounts() async* {
  for (var count = 1; count <= 3; count++) {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield count;
  }
}

Future<void> main() async {
  await for (final count in noticeCounts()) {
    print('공지 $count건');
  }
  print('흐름 종료');
}
