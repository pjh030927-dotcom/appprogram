import 'dart:async';

Future<void> main() async {
  final single = StreamController<int>();
  final values = <int>[];
  final done = Completer<void>();
  single.stream.listen(values.add, onDone: done.complete);
  single.sink.add(1);
  single.sink.add(2);
  await single.close();
  await done.future;
  if (values.join(',') != '1,2') throw StateError('SINGLE_VALUES');
  print('single: ${values.join(',')}');

  final broadcast = StreamController<int>.broadcast();
  broadcast.add(0); // 구독 전 이벤트는 나중 구독을 위해 저장하지 않습니다.
  final first = <int>[];
  final second = <int>[];
  final one = broadcast.stream.listen(first.add);
  final two = broadcast.stream.listen(second.add);
  broadcast.add(3);
  await broadcast.close();
  await one.cancel();
  await two.cancel();
  if (first.join(',') != '3' || second.join(',') != '3') {
    throw StateError('BROADCAST_VALUES');
  }
  print('broadcast: ${first.join(',')} / ${second.join(',')}');
  print('흐름과 구독 정리 완료');
}
