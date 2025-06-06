import 'package:flutter/material.dart';
import 'package:flutter_basic_folderview/flutter_basic_folderview.dart';

import 'mock_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Basic FolderView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TreeViewPage(),
    );
  }
}

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  late List<TreeNode> rootNodes;

  @override
  void initState() {
    super.initState();
    // 테스트 데이터 생성
    rootNodes = MockData.createTestData();
  }

  void _onAccountDoubleClick(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Double Clicked'),
        content: Text('Account: ${account.name}\nID: ${account.id}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onAccountRightClick(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Right Clicked'),
        content: Text('Account: ${account.name}\nID: ${account.id}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _switchToComplexData() {
    setState(() {
      rootNodes = MockData.createComplexTestData();
    });
  }

  void _switchToSimpleData() {
    setState(() {
      rootNodes = MockData.createTestData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Basic FolderView Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 데이터 변경 버튼
          PopupMenuButton<String>(
            icon: const Icon(Icons.data_object),
            tooltip: 'Change Data',
            onSelected: (String value) {
              switch (value) {
                case 'simple':
                  _switchToSimpleData();
                  break;
                case 'complex':
                  _switchToComplexData();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'simple',
                child: Text('Simple Test Data'),
              ),
              const PopupMenuItem<String>(
                value: 'complex',
                child: Text('Complex Test Data'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: TreeView(
          rootNodes: rootNodes,
          onAccountDoubleClick: _onAccountDoubleClick,
          onAccountRightClick: _onAccountRightClick,
          theme: TreeViewThemeData.defaultTheme(),
        ),
      ),
    );
  }
}
