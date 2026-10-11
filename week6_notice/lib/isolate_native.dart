import 'dart:isolate';

int total(int n) {
  var sum = 0;
  for (var i = 1; i <= n; i++) {
    sum += i;
  }
  return sum;
}

Future<void> main() async {
  final mainName = Isolate.current.debugName;
  final result = await Isolate.run(
    () => (name: Isolate.current.debugName, sum: total(100)),
    debugName: 'chapter9-worker',
  );
  if (result.sum != 5050 || result.name != 'chapter9-worker') {
    throw StateError('ISOLATE_RESULT');
  }
  print('main: $mainName');
  print('worker: ${result.name}');
  print('sum: ${result.sum}');
  // 별도 isolate와 결과를 확인합니다. 속도 개선을 측정한 것은 아닙니다.
}
