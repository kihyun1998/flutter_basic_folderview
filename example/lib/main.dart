import 'package:example/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basic_folderview/flutter_basic_folderview.dart';

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
      darkTheme: ThemeData.dark(useMaterial3: true),
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
  String? selectedNodeId;
  String currentTheme = 'default';
  String currentDataSet = 'simple';

  // 🎯 확장 상태를 외부에서 관리
  Set<String> expandedNodeIds = {};

  // 다양한 테마들
  final Map<String, TreeViewThemeData> themes = {
    'default': TreeViewThemeData.defaultTheme(),
    'dark': TreeViewThemeData.darkTheme(),
    'compact': TreeViewThemeData.compactTheme(),
    'custom_blue': TreeViewThemeData.defaultTheme().copyWith(
      folderColor: Colors.blue.shade600,
      folderExpandedColor: Colors.blue.shade800,
      nodeColor: Colors.cyan.shade600,
      nodeExpandedColor: Colors.cyan.shade800,
      accountColor: Colors.teal.shade600,
      backgroundColor: Colors.blue.shade50,
      borderColor: Colors.blue.shade300,
      nodeHoverColor: Colors.blue.shade100,
      nodeSelectedColor: Colors.blue.shade200,
    ),
    'custom_green': TreeViewThemeData.defaultTheme().copyWith(
      folderColor: Colors.green.shade600,
      folderExpandedColor: Colors.green.shade800,
      nodeColor: Colors.lightGreen.shade600,
      nodeExpandedColor: Colors.lightGreen.shade800,
      accountColor: Colors.teal.shade600,
      backgroundColor: Colors.green.shade50,
      borderColor: Colors.green.shade300,
      nodeHoverColor: Colors.green.shade100,
      nodeSelectedColor: Colors.green.shade200,
      nodeBorderRadius: const BorderRadius.all(Radius.circular(12.0)),
      iconSize: 24.0,
    ),
    'minimal': TreeViewThemeData.defaultTheme().copyWith(
      showVerticalScrollbar: false,
      showHorizontalScrollbar: false,
      backgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      borderWidth: 0.0,
      nodeHoverColor: Colors.grey.shade100,
      nodeSelectedColor: Colors.grey.shade200,
      enableRippleEffects: false,
    ),
  };

  @override
  void initState() {
    super.initState();
    rootNodes = ImprovedMockData.createSimpleTestData();
    _initializeExpandedStates();
  }

  // 🎯 초기 확장 상태 설정 (TreeNodeState.isExpanded 기반)
  void _initializeExpandedStates() {
    expandedNodeIds.clear();
    _collectExpandedNodes(rootNodes);
  }

  void _collectExpandedNodes(List<TreeNode> nodes) {
    for (var node in nodes) {
      if ((node is Folder || node is Node) && node.data.isExpanded) {
        expandedNodeIds.add(node.id);
      }
      if (node.children.isNotEmpty) {
        _collectExpandedNodes(node.children.cast<TreeNode>());
      }
    }
  }

  // 🎯 확장/축소 상태 변경 핸들러
  void _onExpansionChanged(String nodeId, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        expandedNodeIds.add(nodeId);
      } else {
        expandedNodeIds.remove(nodeId);
      }
    });
  }

  void _onAccountDoubleClick(Account account) {
    final metadata = account.data.metadata;
    String metadataInfo = 'No metadata';

    if (metadata != null) {
      if (metadata is String) {
        metadataInfo = 'String: "$metadata"';
      } else if (metadata is Map) {
        metadataInfo = 'Map: ${metadata.toString()}';
      } else if (metadata is int) {
        metadataInfo = 'Integer: $metadata';
      } else {
        metadataInfo = '${metadata.runtimeType}: $metadata';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Double Clicked'),
        content: Text(
          'Account: ${account.name}\n'
          'ID: ${account.id}\n'
          'Enabled: ${account.data.isEnabled}\n'
          'Metadata: $metadataInfo',
        ),
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
        content: Text(
          'Account: ${account.name}\n'
          'ID: ${account.id}\n'
          'Enabled: ${account.data.isEnabled}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onNodeTap(TreeNode node) {
    print('Node tapped: ${node.name} (${node.runtimeType})');
  }

  void _onSelectionChanged(String? nodeId) {
    setState(() {
      selectedNodeId = nodeId;
    });
  }

  void _changeTheme(String themeName) {
    setState(() {
      currentTheme = themeName;
    });
  }

  void _changeDataSet(String dataSet) {
    setState(() {
      currentDataSet = dataSet;
      switch (dataSet) {
        case 'simple':
          rootNodes = ImprovedMockData.createSimpleTestData();
          break;
        case 'complex':
          rootNodes = ImprovedMockData.createComplexTestData();
          break;
        case 'mixed_states':
          rootNodes = ImprovedMockData.createMixedStatesTestData();
          break;
        case 'disabled_demo':
          rootNodes = ImprovedMockData.createDisabledNodesDemo();
          break;
      }
      selectedNodeId = null;
      _initializeExpandedStates(); // 데이터 변경 시 확장 상태 재설정
    });
  }

  // 🎯 모든 폴더/노드 확장
  void _expandAll() {
    setState(() {
      expandedNodeIds.clear();
      _addAllExpandableNodes(rootNodes);
    });
  }

  void _addAllExpandableNodes(List<TreeNode> nodes) {
    for (var node in nodes) {
      if ((node is Folder || node is Node) && node.children.isNotEmpty) {
        expandedNodeIds.add(node.id);
        _addAllExpandableNodes(node.children.cast<TreeNode>());
      }
    }
  }

  // 🎯 모든 폴더/노드 축소
  void _collapseAll() {
    setState(() {
      expandedNodeIds.clear();
    });
  }

  // 🎯 특정 노드만 확장 (API 제어 시뮬레이션)
  void _expandSpecificNodes() {
    setState(() {
      expandedNodeIds.clear();
      // 예: 첫 번째 폴더와 그 안의 첫 번째 노드만 확장
      if (rootNodes.isNotEmpty && rootNodes[0] is Folder) {
        expandedNodeIds.add(rootNodes[0].id);
        final firstFolder = rootNodes[0];
        if (firstFolder.children.isNotEmpty) {
          final firstChild = firstFolder.children[0];
          if (firstChild is TreeNode &&
              (firstChild is Folder || firstChild is Node)) {
            expandedNodeIds.add(firstChild.id);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TreeView External State Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 테마 선택 버튼
          PopupMenuButton<String>(
            icon: const Icon(Icons.palette),
            tooltip: 'Change Theme',
            onSelected: _changeTheme,
            itemBuilder: (BuildContext context) => themes.keys.map((theme) {
              return PopupMenuItem<String>(
                value: theme,
                child: Row(
                  children: [
                    if (currentTheme == theme)
                      const Icon(Icons.check, size: 16),
                    if (currentTheme == theme) const SizedBox(width: 8),
                    Text(theme.replaceAll('_', ' ').toUpperCase()),
                  ],
                ),
              );
            }).toList(),
          ),

          // 데이터 세트 선택 버튼
          PopupMenuButton<String>(
            icon: const Icon(Icons.data_object),
            tooltip: 'Change Data',
            onSelected: _changeDataSet,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'simple',
                child: Row(
                  children: [
                    if (currentDataSet == 'simple')
                      const Icon(Icons.check, size: 16),
                    if (currentDataSet == 'simple') const SizedBox(width: 8),
                    const Text('Simple Data'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'complex',
                child: Row(
                  children: [
                    if (currentDataSet == 'complex')
                      const Icon(Icons.check, size: 16),
                    if (currentDataSet == 'complex') const SizedBox(width: 8),
                    const Text('Complex Data'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'mixed_states',
                child: Row(
                  children: [
                    if (currentDataSet == 'mixed_states')
                      const Icon(Icons.check, size: 16),
                    if (currentDataSet == 'mixed_states')
                      const SizedBox(width: 8),
                    const Text('Mixed States'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'disabled_demo',
                child: Row(
                  children: [
                    if (currentDataSet == 'disabled_demo')
                      const Icon(Icons.check, size: 16),
                    if (currentDataSet == 'disabled_demo')
                      const SizedBox(width: 8),
                    const Text('Disabled Demo'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 현재 상태 표시 및 제어 버튼들
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Settings & Controls',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                // 🎯 확장 제어 버튼들
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _expandAll,
                      icon: const Icon(Icons.unfold_more, size: 16),
                      label: const Text('Expand All'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _collapseAll,
                      icon: const Icon(Icons.unfold_less, size: 16),
                      label: const Text('Collapse All'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _expandSpecificNodes,
                      icon: const Icon(Icons.api, size: 16),
                      label: const Text('API Control Demo'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TreeView
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: TreeView(
                rootNodes: rootNodes,
                expandedNodeIds: expandedNodeIds,
                onExpansionChanged: _onExpansionChanged,
                onAccountDoubleClick: _onAccountDoubleClick,
                onAccountRightClick: _onAccountRightClick,
                onNodeTap: _onNodeTap,
                onSelectionChanged: _onSelectionChanged,
                selectedNodeId: selectedNodeId,
                theme: themes[currentTheme],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
