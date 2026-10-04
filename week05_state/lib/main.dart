import 'package:flutter/material.dart';

void main() => runApp(const Week05App());

class Week05App extends StatelessWidget {
  const Week05App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const TaskPage(),
    );
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final List<String> _titles = ['5주차 강의 복습', '상태 흐름도 작성'];

  // TODO(AC1): 두 항목의 완료 여부를 false로 시작하는 상태로 보관한다.
  // 예: final List<bool> _done = [false, false];
  final List<bool> _done = [false, false];

  int get _remaining {
    // TODO(AC3): 완료되지 않은 항목의 수를 원본 상태에서 계산한다.
    return _done.where((isDone) => !isDone).length;
  }

  void _toggleDone(int index) {
    // TODO(AC2): setState 안에서 해당 항목의 완료 여부를 뒤집는다.
    setState(() {
      _done[index] = !_done[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('나의 할 일')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '남은 할 일: $_remaining',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _titles.length; i++)
            Card(
              child: ListTile(
                title: Text(_titles[i]),
                // TODO(AC2): 완료 여부에 따라 아이콘과 버튼 문구를 바꾼다.
                trailing: TextButton(
                  onPressed: () => _toggleDone(i),
                  child: Text(_done[i] ? '미완료' : '완료'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
