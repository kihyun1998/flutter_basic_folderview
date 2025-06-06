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
      selectedNodeId = null; // 데이터 변경 시 선택 초기화
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TreeView Theme Demo'),
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
          // 현재 상태 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Settings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                        'Theme: ${currentTheme.replaceAll('_', ' ').toUpperCase()}'),
                    const SizedBox(width: 24),
                    Text(
                        'Data: ${currentDataSet.replaceAll('_', ' ').toUpperCase()}'),
                    const SizedBox(width: 24),
                    if (selectedNodeId != null)
                      Text('Selected: $selectedNodeId')
                    else
                      const Text('Selected: None'),
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

      // 정보 패널
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInfoDialog(),
        tooltip: 'Show Info',
        child: const Icon(Icons.info),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('TreeView Theme Demo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Available Themes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Default - Standard theme'),
              Text('• Dark - Dark mode theme'),
              Text('• Compact - Smaller spacing'),
              Text('• Custom Blue - Blue color scheme'),
              Text('• Custom Green - Green color scheme'),
              Text('• Minimal - No scrollbars, no borders'),
              SizedBox(height: 16),
              Text(
                'Available Data Sets:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Simple Data - Basic test data'),
              Text('• Complex Data - Large hierarchical data'),
              Text('• Mixed States - Various node states'),
              Text('• Disabled Demo - Shows disabled nodes'),
              SizedBox(height: 16),
              Text(
                'Interactions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Click to select nodes'),
              Text('• Double-click accounts for details'),
              Text('• Right-click accounts for context'),
              Text('• Click folders/nodes to expand/collapse'),
            ],
          ),
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
}
