# flutter_basic_folderview
## Project Structure

```
flutter_basic_folderview/
├── example/
    ├── lib/
    │   ├── main.dart
    │   └── mock_data.dart
    └── pubspec.yaml
├── lib/
    ├── src/
    │   ├── models/
    │   │   ├── tree_node.dart
    │   │   ├── tree_node_state.dart
    │   │   └── tree_view_theme.dart
    │   ├── utils/
    │   │   └── tree_view_width_calculator.dart
    │   └── widgets/
    │   │   ├── custom_expantion_tile.dart
    │   │   ├── custom_inkwell.dart
    │   │   ├── synced_scroll_controllers.dart
    │   │   └── tree_view.dart
    └── flutter_basic_folderview.dart
├── CHANGELOG.md
├── LICENSE
└── pubspec.yaml
```

## CHANGELOG.md
```md
## 0.0.1

* TODO: Describe initial release.

```
## LICENSE
```
TODO: Add your license here.

```
## example/lib/main.dart
```dart
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

```
## example/lib/mock_data.dart
```dart
import 'package:flutter_basic_folderview/flutter_basic_folderview.dart';

// 커스텀 메타데이터 클래스들
class UserInfo {
  final String name;
  final int id;
  final String role;
  final DateTime lastLogin;
  final bool isActive;

  UserInfo({
    required this.name,
    required this.id,
    required this.role,
    required this.lastLogin,
    this.isActive = true,
  });

  @override
  String toString() =>
      'UserInfo(name: $name, id: $id, role: $role, active: $isActive)';
}

class ServerInfo {
  final String host;
  final int port;
  final String status;
  final double cpuUsage;
  final bool isOnline;

  ServerInfo({
    required this.host,
    required this.port,
    required this.status,
    required this.cpuUsage,
    this.isOnline = true,
  });

  @override
  String toString() =>
      'ServerInfo(host: $host:$port, status: $status, cpu: $cpuUsage%, online: $isOnline)';
}

class ImprovedMockData {
  /// 간단한 테스트 데이터 (enabled/disabled 상태 포함)
  static List<TreeNode> createSimpleTestData() {
    // 활성화된 계정들
    final account1 = Account(
      id: 'acc_1',
      name: 'admin@example.com',
      data: TreeNodeState.withStringMetadata("admin_user_123"),
    );

    final account2 = Account(
      id: 'acc_2',
      name: 'user@example.com',
      data: TreeNodeState.withStringMetadata("regular_user_456"),
    );

    // 비활성화된 계정
    final account3 = Account(
      id: 'acc_3',
      name: 'disabled@example.com',
      data: TreeNodeState.disabled(metadata: "disabled_user_789"),
    );

    // 커스텀 객체 메타데이터를 가진 계정
    final account4 = Account(
      id: 'acc_4',
      name: 'guest@domain.com',
      data: TreeNodeState.withMetadata(UserInfo(
        name: 'Guest User',
        id: 789,
        role: 'guest',
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
      )),
    );

    // 활성화된 노드
    final node1 = Node(
      id: 'node_1',
      name: 'Web Server',
      children: [account1, account2],
      data: TreeNodeState.withMetadata(ServerInfo(
        host: '192.168.1.10',
        port: 80,
        status: 'running',
        cpuUsage: 25.5,
        isOnline: true,
      )),
    );

    // 비활성화된 노드
    final node2 = Node(
      id: 'node_2',
      name: 'Maintenance Server',
      children: [account3],
      data: TreeNodeState.disabled(
          metadata: ServerInfo(
        host: '192.168.1.20',
        port: 5432,
        status: 'maintenance',
        cpuUsage: 0.0,
        isOnline: false,
      )),
    );

    // 폴더들
    final folder1 = Folder.create(
      id: 'folder_1',
      name: 'Production',
      children: [node1, node2],
      metadata: {
        'environment': 'production',
        'region': 'us-east-1',
        'criticality': 'high',
      },
    );

    final folder2 = Folder.create(
      id: 'folder_2',
      name: 'Development',
      children: [account4],
      metadata: {
        'environment': 'development',
        'auto_deploy': true,
        'test_coverage': 85.5,
      },
    );

    return [folder1, folder2];
  }

  /// 복잡한 테스트 데이터
  static List<TreeNode> createComplexTestData() {
    final List<TreeNode> nodes = [];

    for (int i = 0; i < 5; i++) {
      final folder = Folder.create(
        id: 'root_folder_$i',
        name: 'Root Folder $i',
        metadata: {
          'level': 'root',
          'index': i,
          'created': DateTime.now().subtract(Duration(days: i)),
        },
      );

      for (int j = 0; j < 3; j++) {
        final subFolder = Folder.create(
          id: 'sub_folder_${i}_$j',
          name: 'Sub Folder $j',
          metadata: 'sub_level_${i}_$j',
        );

        for (int k = 0; k < 4; k++) {
          final node = Node(
            id: 'node_${i}_${j}_$k',
            name: 'Server $i-$j-$k',
            data: TreeNodeState.withMetadata(ServerInfo(
              host: '192.168.$i.$k',
              port: 8000 + k,
              status: k % 3 == 0
                  ? 'running'
                  : (k % 3 == 1 ? 'stopped' : 'maintenance'),
              cpuUsage: (k + 1) * 20.0 + i * 5,
              isOnline: k % 3 != 1,
            )),
          );

          for (int l = 0; l < 3; l++) {
            final account = Account(
              id: 'acc_${i}_${j}_${k}_$l',
              name: 'user$l@server$k.com',
              data: TreeNodeState.withMetadata(UserInfo(
                name: 'User $i-$j-$k-$l',
                id: i * 1000 + j * 100 + k * 10 + l,
                role: l == 0 ? 'admin' : (l == 1 ? 'user' : 'guest'),
                lastLogin: DateTime.now().subtract(Duration(hours: l + k)),
                isActive: l != 2, // guest 계정은 비활성
              )),
            );
            node.children.add(account);
          }

          subFolder.children.add(node);
        }

        folder.children.add(subFolder);
      }

      nodes.add(folder);
    }

    return nodes;
  }

  /// 다양한 상태가 혼재된 테스트 데이터
  static List<TreeNode> createMixedStatesTestData() {
    // 선택된 상태의 계정
    final selectedAccount = Account(
      id: 'selected_acc',
      name: 'selected@example.com',
      data: TreeNodeState.selected(metadata: "selected_user"),
    );

    // 비활성화된 계정
    final disabledAccount = Account(
      id: 'disabled_acc',
      name: 'disabled@example.com',
      data: TreeNodeState.disabled(metadata: "disabled_user"),
    );

    // 숨겨진 계정
    final hiddenAccount = Account(
      id: 'hidden_acc',
      name: 'hidden@example.com',
      data: TreeNodeState.hidden(metadata: "hidden_user"),
    );

    // 일반 계정
    final normalAccount = Account(
      id: 'normal_acc',
      name: 'normal@example.com',
      data: TreeNodeState.withStringMetadata("normal_user"),
    );

    // 다양한 상태의 노드들
    final activeNode = Node(
      id: 'active_node',
      name: 'Active Server',
      children: [selectedAccount, normalAccount],
      data: TreeNodeState.withStringMetadata("active_server"),
    );

    final disabledNode = Node(
      id: 'disabled_node',
      name: 'Disabled Server',
      children: [disabledAccount],
      data: TreeNodeState.disabled(metadata: "disabled_server"),
    );

    // 확장된 폴더
    final expandedFolder = Folder(
      id: 'expanded_folder',
      name: 'Expanded Folder',
      children: [activeNode, disabledNode],
      data: TreeNodeState(
        isExpanded: true,
        metadata: "expanded_folder_data",
      ),
    );

    // 축소된 폴더
    final collapsedFolder = Folder(
      id: 'collapsed_folder',
      name: 'Collapsed Folder',
      children: [hiddenAccount],
      data: TreeNodeState(
        isExpanded: false,
        metadata: "collapsed_folder_data",
      ),
    );

    return [expandedFolder, collapsedFolder];
  }

  /// disabled 노드들의 데모 데이터
  static List<TreeNode> createDisabledNodesDemo() {
    // 활성 계정들
    final activeAccount1 = Account(
      id: 'active_1',
      name: 'active.user1@company.com',
      data: TreeNodeState.withStringMetadata("Active user 1"),
    );

    final activeAccount2 = Account(
      id: 'active_2',
      name: 'active.user2@company.com',
      data: TreeNodeState.withStringMetadata("Active user 2"),
    );

    // 비활성 계정들
    final disabledAccount1 = Account(
      id: 'disabled_1',
      name: 'disabled.user1@company.com',
      data: TreeNodeState.disabled(metadata: "Disabled user 1 - Suspended"),
    );

    final disabledAccount2 = Account(
      id: 'disabled_2',
      name: 'disabled.user2@company.com',
      data: TreeNodeState.disabled(metadata: "Disabled user 2 - Terminated"),
    );

    final disabledAccount3 = Account(
      id: 'disabled_3',
      name: 'disabled.user3@company.com',
      data: TreeNodeState.disabled(metadata: "Disabled user 3 - On leave"),
    );

    // 활성 서버
    final activeServer = Node(
      id: 'active_server',
      name: 'Production Server',
      children: [activeAccount1, activeAccount2],
      data: TreeNodeState.withMetadata(ServerInfo(
        host: '10.0.1.100',
        port: 80,
        status: 'running',
        cpuUsage: 45.2,
        isOnline: true,
      )),
    );

    // 비활성 서버
    final disabledServer = Node(
      id: 'disabled_server',
      name: 'Maintenance Server',
      children: [disabledAccount1, disabledAccount2],
      data: TreeNodeState.disabled(
          metadata: ServerInfo(
        host: '10.0.1.200',
        port: 80,
        status: 'maintenance',
        cpuUsage: 0.0,
        isOnline: false,
      )),
    );

    // 부분적으로 비활성화된 서버 (일부 계정만 비활성)
    final partiallyDisabledServer = Node(
      id: 'partial_server',
      name: 'Development Server',
      children: [activeAccount1, disabledAccount3],
      data: TreeNodeState.withMetadata(ServerInfo(
        host: '10.0.1.300',
        port: 8080,
        status: 'running',
        cpuUsage: 15.8,
        isOnline: true,
      )),
    );

    // 활성 부서 폴더
    final activeDept = Folder.create(
      id: 'active_dept',
      name: 'Active Department',
      children: [activeServer],
      metadata: {
        'department': 'Engineering',
        'status': 'active',
        'employee_count': 25,
      },
    );

    // 비활성 부서 폴더
    final disabledDept = Folder.create(
      id: 'disabled_dept',
      name: 'Disabled Department',
      children: [disabledServer],
      metadata: {
        'department': 'Legacy Systems',
        'status': 'discontinued',
        'employee_count': 0,
      },
    );

    // 혼합 상태 부서 폴더
    final mixedDept = Folder.create(
      id: 'mixed_dept',
      name: 'Mixed Status Department',
      children: [partiallyDisabledServer],
      metadata: {
        'department': 'Research & Development',
        'status': 'restructuring',
        'employee_count': 12,
      },
    );

    return [activeDept, disabledDept, mixedDept];
  }

  /// 메타데이터 사용 예제 시연
  static void demonstrateImprovedMetadataUsage(List<TreeNode> nodes) {
    print('=== 개선된 메타데이터 사용 예제 ===');

    void printNodeInfo(TreeNode node, int depth) {
      final indent = '  ' * depth;
      final state = node.data;

      print('$indent${node.name} (${node.runtimeType})');
      print('$indent  └─ Enabled: ${state.isEnabled}');
      print('$indent  └─ Expanded: ${state.isExpanded}');
      print('$indent  └─ Selected: ${state.isSelected}');
      print('$indent  └─ Visible: ${state.isVisible}');

      if (state.hasMetadata) {
        final metadata = state.metadata;
        print('$indent  └─ Metadata: ${metadata.runtimeType}');

        if (metadata is UserInfo) {
          print(
              '$indent     UserInfo: ${metadata.name} (${metadata.role}, active: ${metadata.isActive})');
        } else if (metadata is ServerInfo) {
          print(
              '$indent     ServerInfo: ${metadata.host}:${metadata.port} (${metadata.status}, online: ${metadata.isOnline})');
        } else if (metadata is Map) {
          print('$indent     Map keys: ${metadata.keys.join(', ')}');
        } else if (metadata is String) {
          print('$indent     String: "$metadata"');
        }

        // 타입 안전한 접근 예제
        final userInfo = state.getMetadataAs<UserInfo>();
        final serverInfo = state.getMetadataAs<ServerInfo>();

        if (userInfo != null) {
          print(
              '$indent     └─ Safe access: User ${userInfo.name} is ${userInfo.isActive ? 'active' : 'inactive'}');
        } else if (serverInfo != null) {
          print(
              '$indent     └─ Safe access: Server ${serverInfo.host} is ${serverInfo.isOnline ? 'online' : 'offline'}');
        }
      } else {
        print('$indent  └─ Metadata: null');
      }

      // 자식 노드들도 순회
      for (final child in node.children) {
        if (child is TreeNode) {
          printNodeInfo(child, depth + 1);
        }
      }
    }

    for (final node in nodes) {
      printNodeInfo(node, 0);
      print(''); // 빈 줄로 구분
    }
  }

  /// 노드 상태 통계 출력
  static void printNodeStatistics(List<TreeNode> nodes) {
    int totalNodes = 0;
    int enabledNodes = 0;
    int disabledNodes = 0;
    int expandedNodes = 0;
    int selectedNodes = 0;
    int hiddenNodes = 0;

    void countNodes(List<TreeNode> nodeList) {
      for (final node in nodeList) {
        totalNodes++;

        if (node.data.isEnabled) enabledNodes++;
        if (!node.data.isEnabled) disabledNodes++;
        if (node.data.isExpanded) expandedNodes++;
        if (node.data.isSelected) selectedNodes++;
        if (!node.data.isVisible) hiddenNodes++;

        if (node.children.isNotEmpty) {
          countNodes(node.children.cast<TreeNode>());
        }
      }
    }

    countNodes(nodes);

    print('=== 노드 상태 통계 ===');
    print('총 노드 수: $totalNodes');
    print('활성 노드: $enabledNodes');
    print('비활성 노드: $disabledNodes');
    print('확장된 노드: $expandedNodes');
    print('선택된 노드: $selectedNodes');
    print('숨겨진 노드: $hiddenNodes');
  }
}

```
## example/pubspec.yaml
```yaml
name: example
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.6.1

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  flutter_basic_folderview:
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^5.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package

```
## lib/flutter_basic_folderview.dart
```dart
library;

// Models
export 'src/models/tree_node.dart';
export 'src/models/tree_node_state.dart';
export 'src/models/tree_view_theme.dart';
export 'src/utils/tree_view_width_calculator.dart';
// Main widget
export 'src/widgets/tree_view.dart';

```
## lib/src/models/tree_node.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'tree_node_state.dart';

/// 모든 트리 노드의 기본 추상 클래스
/// 모든 노드는 TreeNodeState를 data로 사용하여 일관성 확보
abstract class TreeNode {
  final String id;
  final String name;
  final List<dynamic> children;
  final TreeNodeState data;

  TreeNode({
    required this.id,
    required this.name,
    List<dynamic>? children,
    required this.data,
  }) : children = children ?? [];

  TreeNode copyWith({
    String? id,
    String? name,
    List<dynamic>? children,
    TreeNodeState? data,
  });
}

/// 서버나 노드를 나타내는 클래스
class Node extends TreeNode {
  Node({
    required super.id,
    required super.name,
    super.children,
    required super.data,
  });

  @override
  Node copyWith({
    String? id,
    String? name,
    List<dynamic>? children,
    TreeNodeState? data,
  }) {
    return Node(
      id: id ?? this.id,
      name: name ?? this.name,
      children: children ?? this.children,
      data: data ?? this.data,
    );
  }
}

/// 계정이나 사용자를 나타내는 클래스
class Account extends TreeNode {
  Account({
    required super.id,
    required super.name,
    super.children,
    required super.data,
  });

  factory Account.init() => Account(
        id: "",
        name: "",
        data: TreeNodeState.init(),
      );

  @override
  Account copyWith({
    String? id,
    String? name,
    List<dynamic>? children,
    TreeNodeState? data,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      children: children ?? this.children,
      data: data ?? this.data,
    );
  }
}

/// 폴더나 그룹을 나타내는 클래스
/// 이제 TreeNodeState를 사용하여 확장/축소 상태를 관리
class Folder extends TreeNode {
  Folder({
    required super.id,
    required super.name,
    super.children,
    required super.data,
  });

  /// 간편한 생성을 위한 팩토리 (확장되지 않은 상태로 시작)
  factory Folder.create({
    required String id,
    required String name,
    List<dynamic>? children,
    dynamic metadata,
  }) {
    return Folder(
      id: id,
      name: name,
      children: children,
      data: TreeNodeState(
        isExpanded: false, // 폴더는 기본적으로 접혀있음
        metadata: metadata,
      ),
    );
  }

  /// 기존 호환성을 위한 팩토리 (bool 값을 isExpanded로 변환)
  factory Folder.fromBool({
    required String id,
    required String name,
    List<dynamic>? children,
    bool isExpanded = false,
    dynamic metadata,
  }) {
    return Folder(
      id: id,
      name: name,
      children: children,
      data: TreeNodeState(
        isExpanded: isExpanded,
        metadata: metadata,
      ),
    );
  }

  factory Folder.init() => Folder.create(id: "", name: "");

  /// 폴더의 확장 상태를 편리하게 접근
  bool get isExpanded => data.isExpanded;

  /// 폴더의 확장 상태를 변경한 새 인스턴스 반환
  Folder toggleExpanded() {
    return copyWith(
      data: data.copyWith(isExpanded: !data.isExpanded),
    );
  }

  /// 폴더를 확장된 상태로 설정
  Folder expand() {
    return copyWith(
      data: data.copyWith(isExpanded: true),
    );
  }

  /// 폴더를 축소된 상태로 설정
  Folder collapse() {
    return copyWith(
      data: data.copyWith(isExpanded: false),
    );
  }

  @override
  Folder copyWith({
    String? id,
    String? name,
    List<dynamic>? children,
    TreeNodeState? data,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      children: children ?? this.children,
      data: data ?? this.data,
    );
  }
}

/// TreeNode 확장 메서드들
extension TreeNodeExtensions on TreeNode {
  /// 노드가 확장 가능한지 확인 (자식이 있는지)
  bool get canExpand => children.isNotEmpty;

  /// 노드가 현재 확장되어 있는지 확인
  bool get isExpanded => data.isExpanded;

  /// 노드가 선택되어 있는지 확인
  bool get isSelected => data.isSelected;

  /// 노드가 활성화되어 있는지 확인
  bool get isEnabled => data.isEnabled;

  /// 노드가 보이는지 확인
  bool get isVisible => data.isVisible;

  /// 메타데이터가 있는지 확인
  bool get hasMetadata => data.hasMetadata;

  /// 안전한 메타데이터 접근
  T? getMetadataAs<T>() => data.getMetadataAs<T>();

  /// 노드 타입 확인 헬퍼들
  bool get isFolder => this is Folder;
  bool get isNode => this is Node;
  bool get isAccount => this is Account;
}

```
## lib/src/models/tree_node_state.dart
```dart
class TreeNodeState {
  final bool isSelected;
  final bool isExpanded;
  final bool isEnabled;
  final bool isVisible;
  final dynamic metadata; // Map, String, int, 커스텀 객체 등 무엇이든 가능

  TreeNodeState({
    this.isSelected = false,
    this.isExpanded = false,
    this.isEnabled = true,
    this.isVisible = true,
    this.metadata,
  });

  factory TreeNodeState.init() {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      isEnabled: true,
      isVisible: true,
      metadata: null,
    );
  }

  // 사용자의 기존 코드에서 사용되는 fromPathUser 팩토리
  factory TreeNodeState.fromPathUser(dynamic pathUser) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      isEnabled: true,
      isVisible: true,
      metadata: pathUser, // 바로 pathUser를 metadata로 저장
    );
  }

  // 편의를 위한 추가 팩토리들
  factory TreeNodeState.withMetadata(dynamic metadata) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      isEnabled: true,
      isVisible: true,
      metadata: metadata,
    );
  }

  factory TreeNodeState.withStringMetadata(String metadata) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      isEnabled: true,
      isVisible: true,
      metadata: metadata,
    );
  }

  factory TreeNodeState.withMapMetadata(Map<String, dynamic> metadata) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      isEnabled: true,
      isVisible: true,
      metadata: metadata,
    );
  }

  factory TreeNodeState.withIntMetadata(int metadata) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      isEnabled: true,
      isVisible: true,
      metadata: metadata,
    );
  }

  // 상태별 팩토리들
  factory TreeNodeState.disabled({dynamic metadata}) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      isEnabled: false,
      isVisible: true,
      metadata: metadata,
    );
  }

  factory TreeNodeState.hidden({dynamic metadata}) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      isEnabled: true,
      isVisible: false,
      metadata: metadata,
    );
  }

  factory TreeNodeState.selected({dynamic metadata}) {
    return TreeNodeState(
      isSelected: true,
      isExpanded: false,
      isEnabled: true,
      isVisible: true,
      metadata: metadata,
    );
  }

  TreeNodeState copyWith({
    bool? isSelected,
    bool? isExpanded,
    bool? isEnabled,
    bool? isVisible,
    dynamic metadata,
  }) {
    return TreeNodeState(
      isSelected: isSelected ?? this.isSelected,
      isExpanded: isExpanded ?? this.isExpanded,
      isEnabled: isEnabled ?? this.isEnabled,
      isVisible: isVisible ?? this.isVisible,
      metadata: metadata ?? this.metadata,
    );
  }

  // 타입 안전한 메타데이터 접근을 위한 헬퍼 메서드들
  T? getMetadataAs<T>() {
    if (metadata is T) {
      return metadata as T;
    }
    return null;
  }

  Map<String, dynamic>? get metadataAsMap {
    if (metadata is Map<String, dynamic>) {
      return metadata as Map<String, dynamic>;
    }
    return null;
  }

  String? get metadataAsString {
    if (metadata is String) {
      return metadata as String;
    }
    return metadata?.toString();
  }

  int? get metadataAsInt {
    if (metadata is int) {
      return metadata as int;
    }
    if (metadata is String) {
      return int.tryParse(metadata);
    }
    return null;
  }

  double? get metadataAsDouble {
    if (metadata is double) {
      return metadata as double;
    }
    if (metadata is int) {
      return metadata.toDouble();
    }
    if (metadata is String) {
      return double.tryParse(metadata);
    }
    return null;
  }

  bool? get metadataAsBool {
    if (metadata is bool) {
      return metadata as bool;
    }
    if (metadata is String) {
      return metadata.toLowerCase() == 'true';
    }
    if (metadata is int) {
      return metadata != 0;
    }
    return null;
  }

  // 메타데이터 존재 여부 확인
  bool get hasMetadata => metadata != null;

  // 특정 타입인지 확인
  bool isMetadataType<T>() => metadata is T;

  @override
  String toString() {
    return 'TreeNodeState(isSelected: $isSelected, isExpanded: $isExpanded, isEnabled: $isEnabled, isVisible: $isVisible, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TreeNodeState &&
        other.isSelected == isSelected &&
        other.isExpanded == isExpanded &&
        other.isEnabled == isEnabled &&
        other.isVisible == isVisible &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return isSelected.hashCode ^
        isExpanded.hashCode ^
        isEnabled.hashCode ^
        isVisible.hashCode ^
        metadata.hashCode;
  }
}

```
## lib/src/models/tree_view_theme.dart
```dart
import 'package:flutter/material.dart';

/// 완전히 개선된 TreeView 테마 데이터
class TreeViewThemeData {
  // 스크롤바 설정
  final bool showVerticalScrollbar;
  final bool showHorizontalScrollbar;
  final double scrollbarWidth;
  final Color scrollbarColor;
  final Color scrollbarTrackColor;
  final bool scrollbarHoverOnly;
  final double scrollbarOpacity;
  final double scrollbarHoverOpacity;

  // 노드 스타일
  final double nodeVerticalPadding;
  final double nodeHorizontalPadding;
  final double iconSize;
  final double iconSpacing;
  final BorderRadius nodeBorderRadius;
  final Color? nodeHoverColor;
  final Color? nodeSelectedColor;
  final Color? nodeDisabledColor;
  final double nodeMinHeight;

  // 아이콘 색상
  final Color folderColor;
  final Color folderExpandedColor;
  final Color nodeColor;
  final Color nodeExpandedColor;
  final Color accountColor;
  final Color arrowColor;
  final Color disabledIconColor;

  // 전체 레이아웃
  final double indentSize;
  final double nodeSpacing;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  // 텍스트 스타일
  final TextStyle folderTextStyle;
  final TextStyle nodeTextStyle;
  final TextStyle accountTextStyle;
  final TextStyle disabledTextStyle;
  final TextStyle selectedTextStyle;

  // 애니메이션 설정
  final Duration expansionAnimationDuration;
  final Duration hoverAnimationDuration;
  final Curve expansionCurve;

  // 상호작용 설정
  final bool enableHoverEffects;
  final bool enableRippleEffects;
  final Color? rippleColor;

  const TreeViewThemeData({
    // 스크롤바 기본값
    this.showVerticalScrollbar = true,
    this.showHorizontalScrollbar = true,
    this.scrollbarWidth = 12.0,
    this.scrollbarColor = const Color(0xFF757575),
    this.scrollbarTrackColor = const Color(0x1A000000),
    this.scrollbarHoverOnly = true,
    this.scrollbarOpacity = 0.7,
    this.scrollbarHoverOpacity = 0.9,

    // 노드 스타일 기본값
    this.nodeVerticalPadding = 4.0,
    this.nodeHorizontalPadding = 8.0,
    this.iconSize = 20.0,
    this.iconSpacing = 8.0,
    this.nodeBorderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.nodeHoverColor,
    this.nodeSelectedColor,
    this.nodeDisabledColor,
    this.nodeMinHeight = 32.0,

    // 아이콘 색상 기본값
    this.folderColor = const Color(0xFFFFB300),
    this.folderExpandedColor = const Color(0xFFFFA000),
    this.nodeColor = const Color(0xFF1976D2),
    this.nodeExpandedColor = const Color(0xFF1565C0),
    this.accountColor = const Color(0xFF388E3C),
    this.arrowColor = const Color(0xFF757575),
    this.disabledIconColor = const Color(0xFFBDBDBD),

    // 레이아웃 기본값
    this.indentSize = 24.0,
    this.nodeSpacing = 4.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),

    // 텍스트 스타일 기본값
    this.folderTextStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    this.nodeTextStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    this.accountTextStyle = const TextStyle(
      fontSize: 14,
    ),
    this.disabledTextStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF9E9E9E),
    ),
    this.selectedTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),

    // 애니메이션 설정
    this.expansionAnimationDuration = const Duration(milliseconds: 200),
    this.hoverAnimationDuration = const Duration(milliseconds: 150),
    this.expansionCurve = Curves.easeInOut,

    // 상호작용 설정
    this.enableHoverEffects = true,
    this.enableRippleEffects = true,
    this.rippleColor,
  });

  /// 기본 테마 생성
  factory TreeViewThemeData.defaultTheme() {
    return const TreeViewThemeData();
  }

  /// 다크 테마 생성
  factory TreeViewThemeData.darkTheme() {
    return const TreeViewThemeData(
      backgroundColor: Color(0xFF121212),
      borderColor: Color(0xFF333333),
      nodeHoverColor: Color(0xFF2C2C2C),
      nodeSelectedColor: Color(0xFF1976D2),
      folderColor: Color(0xFFFFCA28),
      folderExpandedColor: Color(0xFFFFB300),
      nodeColor: Color(0xFF64B5F6),
      nodeExpandedColor: Color(0xFF42A5F5),
      accountColor: Color(0xFF81C784),
      arrowColor: Color(0xFFBDBDBD),
      folderTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: Colors.white,
      ),
      nodeTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: Colors.white,
      ),
      accountTextStyle: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
      scrollbarColor: Color(0xFF757575),
      scrollbarTrackColor: Color(0x1AFFFFFF),
    );
  }

  /// 컴팩트 테마 생성
  factory TreeViewThemeData.compactTheme() {
    return const TreeViewThemeData(
      nodeVerticalPadding: 2.0,
      nodeHorizontalPadding: 4.0,
      iconSize: 16.0,
      iconSpacing: 6.0,
      indentSize: 20.0,
      nodeSpacing: 2.0,
      nodeMinHeight: 24.0,
      folderTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      nodeTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      accountTextStyle: TextStyle(
        fontSize: 12,
      ),
    );
  }

  TreeViewThemeData copyWith({
    bool? showVerticalScrollbar,
    bool? showHorizontalScrollbar,
    double? scrollbarWidth,
    Color? scrollbarColor,
    Color? scrollbarTrackColor,
    bool? scrollbarHoverOnly,
    double? scrollbarOpacity,
    double? scrollbarHoverOpacity,
    double? nodeVerticalPadding,
    double? nodeHorizontalPadding,
    double? iconSize,
    double? iconSpacing,
    BorderRadius? nodeBorderRadius,
    Color? nodeHoverColor,
    Color? nodeSelectedColor,
    Color? nodeDisabledColor,
    double? nodeMinHeight,
    Color? folderColor,
    Color? folderExpandedColor,
    Color? nodeColor,
    Color? nodeExpandedColor,
    Color? accountColor,
    Color? arrowColor,
    Color? disabledIconColor,
    double? indentSize,
    double? nodeSpacing,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    TextStyle? folderTextStyle,
    TextStyle? nodeTextStyle,
    TextStyle? accountTextStyle,
    TextStyle? disabledTextStyle,
    TextStyle? selectedTextStyle,
    Duration? expansionAnimationDuration,
    Duration? hoverAnimationDuration,
    Curve? expansionCurve,
    bool? enableHoverEffects,
    bool? enableRippleEffects,
    Color? rippleColor,
  }) {
    return TreeViewThemeData(
      showVerticalScrollbar:
          showVerticalScrollbar ?? this.showVerticalScrollbar,
      showHorizontalScrollbar:
          showHorizontalScrollbar ?? this.showHorizontalScrollbar,
      scrollbarWidth: scrollbarWidth ?? this.scrollbarWidth,
      scrollbarColor: scrollbarColor ?? this.scrollbarColor,
      scrollbarTrackColor: scrollbarTrackColor ?? this.scrollbarTrackColor,
      scrollbarHoverOnly: scrollbarHoverOnly ?? this.scrollbarHoverOnly,
      scrollbarOpacity: scrollbarOpacity ?? this.scrollbarOpacity,
      scrollbarHoverOpacity:
          scrollbarHoverOpacity ?? this.scrollbarHoverOpacity,
      nodeVerticalPadding: nodeVerticalPadding ?? this.nodeVerticalPadding,
      nodeHorizontalPadding:
          nodeHorizontalPadding ?? this.nodeHorizontalPadding,
      iconSize: iconSize ?? this.iconSize,
      iconSpacing: iconSpacing ?? this.iconSpacing,
      nodeBorderRadius: nodeBorderRadius ?? this.nodeBorderRadius,
      nodeHoverColor: nodeHoverColor ?? this.nodeHoverColor,
      nodeSelectedColor: nodeSelectedColor ?? this.nodeSelectedColor,
      nodeDisabledColor: nodeDisabledColor ?? this.nodeDisabledColor,
      nodeMinHeight: nodeMinHeight ?? this.nodeMinHeight,
      folderColor: folderColor ?? this.folderColor,
      folderExpandedColor: folderExpandedColor ?? this.folderExpandedColor,
      nodeColor: nodeColor ?? this.nodeColor,
      nodeExpandedColor: nodeExpandedColor ?? this.nodeExpandedColor,
      accountColor: accountColor ?? this.accountColor,
      arrowColor: arrowColor ?? this.arrowColor,
      disabledIconColor: disabledIconColor ?? this.disabledIconColor,
      indentSize: indentSize ?? this.indentSize,
      nodeSpacing: nodeSpacing ?? this.nodeSpacing,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      folderTextStyle: folderTextStyle ?? this.folderTextStyle,
      nodeTextStyle: nodeTextStyle ?? this.nodeTextStyle,
      accountTextStyle: accountTextStyle ?? this.accountTextStyle,
      disabledTextStyle: disabledTextStyle ?? this.disabledTextStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      expansionAnimationDuration:
          expansionAnimationDuration ?? this.expansionAnimationDuration,
      hoverAnimationDuration:
          hoverAnimationDuration ?? this.hoverAnimationDuration,
      expansionCurve: expansionCurve ?? this.expansionCurve,
      enableHoverEffects: enableHoverEffects ?? this.enableHoverEffects,
      enableRippleEffects: enableRippleEffects ?? this.enableRippleEffects,
      rippleColor: rippleColor ?? this.rippleColor,
    );
  }

  // 색상 계산 헬퍼들
  Color getEffectiveNodeHoverColor(BuildContext context) {
    return nodeHoverColor ?? Theme.of(context).hoverColor;
  }

  Color getEffectiveNodeSelectedColor(BuildContext context) {
    return nodeSelectedColor ?? Theme.of(context).primaryColor.withOpacity(0.1);
  }

  Color getEffectiveNodeDisabledColor(BuildContext context) {
    return nodeDisabledColor ??
        Theme.of(context).disabledColor.withOpacity(0.1);
  }

  Color getEffectiveRippleColor(BuildContext context) {
    return rippleColor ?? Theme.of(context).splashColor;
  }

  Color getEffectiveBorderColor(BuildContext context) {
    return borderColor ?? Theme.of(context).dividerColor;
  }
}

```
## lib/src/utils/tree_view_width_calculator.dart
```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/tree_node.dart';
import '../models/tree_view_theme.dart';

/// TreeView의 너비 계산을 담당하는 유틸리티 클래스
class TreeViewWidthCalculator {
  final TreeViewThemeData theme;
  final TextDirection textDirection;

  TreeViewWidthCalculator({
    required this.theme,
    this.textDirection = TextDirection.ltr,
  });

  /// 주어진 트리 노드들의 최대 너비를 계산
  double calculateContentWidth(List<TreeNode> rootNodes) {
    double maxWidth = 0.0;

    void traverseNodes(List<TreeNode> nodes, int depth) {
      for (final node in nodes) {
        final nodeWidth = _calculateNodeWidth(node, depth);
        maxWidth = math.max(maxWidth, nodeWidth);

        // 자식 노드들도 순회 (확장 상태와 관계없이 최대 너비 계산)
        if (node.children.isNotEmpty) {
          traverseNodes(node.children.cast<TreeNode>(), depth + 1);
        }
      }
    }

    traverseNodes(rootNodes, 0);

    // 최소 너비 보장 및 여유 공간 추가
    return math.max(maxWidth + _getRightMargin(), _getMinimumWidth());
  }

  /// 개별 노드의 너비를 계산
  double _calculateNodeWidth(TreeNode node, int depth) {
    // 기본 구성 요소들의 너비
    final indentWidth = theme.indentSize * depth;
    final arrowWidth = 20.0; // 화살표 아이콘 너비 고정
    final iconWidth = theme.iconSize;
    final iconSpacing = theme.iconSpacing;
    final horizontalPadding = theme.nodeHorizontalPadding * 2;
    final contentPadding = 8.0 * 2; // 콘텐츠 패딩 고정

    // 텍스트 너비 계산
    final textWidth = _calculateTextWidth(node);

    return indentWidth +
        arrowWidth +
        contentPadding +
        iconWidth +
        iconSpacing +
        textWidth +
        horizontalPadding;
  }

  /// 텍스트의 실제 렌더링 너비를 계산
  double _calculateTextWidth(TreeNode node) {
    final TextStyle textStyle = _getTextStyleForNode(node);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: node.name,
        style: textStyle,
      ),
      maxLines: 1,
      textDirection: textDirection,
    );

    textPainter.layout();
    final width = textPainter.size.width;
    textPainter.dispose();

    return width;
  }

  /// 노드 타입에 따른 텍스트 스타일 반환
  TextStyle _getTextStyleForNode(TreeNode node) {
    if (node is Folder) {
      return theme.folderTextStyle;
    } else if (node is Node) {
      return theme.nodeTextStyle;
    } else if (node is Account) {
      return theme.accountTextStyle;
    }
    return theme.accountTextStyle; // 기본값
  }

  /// 확장된 노드들만 고려한 현재 표시 너비 계산
  double calculateVisibleContentWidth(
    List<TreeNode> rootNodes,
    Map<String, bool> expandedNodes,
  ) {
    double maxWidth = 0.0;

    void traverseVisibleNodes(List<TreeNode> nodes, int depth) {
      for (final node in nodes) {
        final nodeWidth = _calculateNodeWidth(node, depth);
        maxWidth = math.max(maxWidth, nodeWidth);

        // 확장된 노드의 자식들만 순회
        if (node.children.isNotEmpty && (expandedNodes[node.id] ?? false)) {
          traverseVisibleNodes(node.children.cast<TreeNode>(), depth + 1);
        }
      }
    }

    traverseVisibleNodes(rootNodes, 0);

    return math.max(maxWidth + _getRightMargin(), _getMinimumWidth());
  }

  /// 트리의 최대 깊이 계산
  int calculateMaxDepth(List<TreeNode> rootNodes) {
    int maxDepth = 0;

    void traverseForDepth(List<TreeNode> nodes, int currentDepth) {
      maxDepth = math.max(maxDepth, currentDepth);

      for (final node in nodes) {
        if (node.children.isNotEmpty) {
          traverseForDepth(node.children.cast<TreeNode>(), currentDepth + 1);
        }
      }
    }

    traverseForDepth(rootNodes, 0);
    return maxDepth;
  }

  /// 우측 여유 공간
  double _getRightMargin() => 16.0;

  /// 최소 너비 보장
  double _getMinimumWidth() => 200.0;
}

/// TreeView 너비 계산 관련 확장 메서드
extension TreeViewWidthExtensions on List<TreeNode> {
  /// 간편한 너비 계산 메서드
  double calculateContentWidth(TreeViewThemeData theme) {
    final calculator = TreeViewWidthCalculator(theme: theme);
    return calculator.calculateContentWidth(this);
  }

  /// 현재 표시되는 너비만 계산
  double calculateVisibleWidth(
    TreeViewThemeData theme,
    Map<String, bool> expandedNodes,
  ) {
    final calculator = TreeViewWidthCalculator(theme: theme);
    return calculator.calculateVisibleContentWidth(this, expandedNodes);
  }
}

```
## lib/src/widgets/custom_expantion_tile.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget leading;
  final List<Widget> children;
  final bool isExpanded;
  final double spacing;
  final ValueChanged<bool>? onExpansionChanged;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.leading,
    required this.children,
    required this.isExpanded,
    required this.spacing,
    this.onExpansionChanged,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomExpansionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _isExpanded = widget.isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _handleTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: widget.spacing),
            child: Row(
              children: [
                RotationTransition(
                  turns: _iconTurns,
                  child: widget.leading,
                ),
                const SizedBox(width: 4),
                widget.title,
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(), // 빈값
          secondChild: Column(children: widget.children),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 150),
        ),
      ],
    );
  }
}

```
## lib/src/widgets/custom_inkwell.dart
```dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomInkwell extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onRightClick;
  final BorderRadius? borderRadius;
  final Color? hoverColor;
  final Color? splashColor;

  const CustomInkwell({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onRightClick,
    this.borderRadius,
    this.hoverColor,
    this.splashColor,
  });

  @override
  State<CustomInkwell> createState() => _CustomInkwellState();
}

class _CustomInkwellState extends State<CustomInkwell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          // 우클릭 처리
          if (event.kind == PointerDeviceKind.mouse &&
              event.buttons == kSecondaryMouseButton) {
            widget.onRightClick?.call();
          }
        },
        child: InkWell(
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          hoverColor: widget.hoverColor ?? Theme.of(context).hoverColor,
          splashColor: widget.splashColor ?? Theme.of(context).splashColor,
          child: Container(
            decoration: BoxDecoration(
              color: _isHovered
                  ? (widget.hoverColor ??
                      Theme.of(context).hoverColor.withOpacity(0.1))
                  : Colors.transparent,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

```
## lib/src/widgets/synced_scroll_controllers.dart
```dart
import 'package:flutter/material.dart';

/// 여러 ScrollController를 동기화해주는 위젯
/// 수직/수평 스크롤을 각각 메인 컨트롤러와 스크롤바 컨트롤러로 동기화합니다.
class SyncedScrollControllers extends StatefulWidget {
  const SyncedScrollControllers({
    super.key,
    required this.builder,
    this.scrollController,
    this.verticalScrollbarController,
    this.horizontalScrollController,
    this.horizontalScrollbarController,
  });

  final ScrollController? scrollController;
  final ScrollController? verticalScrollbarController;
  final ScrollController? horizontalScrollController;
  final ScrollController? horizontalScrollbarController;

  final Widget Function(
    BuildContext context,
    ScrollController verticalDataController,
    ScrollController verticalScrollbarController,
    ScrollController horizontalMainController,
    ScrollController horizontalScrollbarController,
  ) builder;

  @override
  State<SyncedScrollControllers> createState() =>
      _SyncedScrollControllersState();
}

class _SyncedScrollControllersState extends State<SyncedScrollControllers> {
  ScrollController? _sc11; // 메인 수직 (ListView 용)
  late ScrollController _sc12; // 수직 스크롤바
  ScrollController? _sc21; // 메인 수평 (헤더 & 데이터 공통)
  late ScrollController _sc22; // 수평 스크롤바

  // 각 컨트롤러에 대한 리스너들을 명확하게 관리하기 위한 Map
  final Map<ScrollController, VoidCallback> _listenersMap = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(SyncedScrollControllers oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeOrUnsubscribe();
    _initControllers();
  }

  @override
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  void _initControllers() {
    _doNotReissueJump.clear();

    // 수직 스크롤 컨트롤러 (메인, ListView 용)
    _sc11 = widget.scrollController ?? ScrollController();

    // 수평 스크롤 컨트롤러 (메인, 헤더와 데이터 영역의 가로 스크롤 공통)
    _sc21 = widget.horizontalScrollController ?? ScrollController();

    // 수직 스크롤바 컨트롤러
    _sc12 = widget.verticalScrollbarController ??
        ScrollController(
          initialScrollOffset: _sc11!.hasClients && _sc11!.positions.isNotEmpty
              ? _sc11!.offset
              : 0.0,
        );

    // 수평 스크롤바 컨트롤러
    _sc22 = widget.horizontalScrollbarController ??
        ScrollController(
          initialScrollOffset: _sc21!.hasClients && _sc21!.positions.isNotEmpty
              ? _sc21!.offset
              : 0.0,
        );

    // 각 쌍의 컨트롤러를 동기화합니다.
    _syncScrollControllers(_sc11!, _sc12);
    _syncScrollControllers(_sc21!, _sc22);
  }

  void _disposeOrUnsubscribe() {
    // 모든 리스너 제거
    _listenersMap.forEach((controller, listener) {
      controller.removeListener(listener);
    });
    _listenersMap.clear();

    // 위젯에서 제공된 컨트롤러가 아니면 직접 dispose
    if (widget.scrollController == null) _sc11?.dispose();
    if (widget.horizontalScrollController == null) _sc21?.dispose();
    if (widget.verticalScrollbarController == null) _sc12.dispose();
    if (widget.horizontalScrollbarController == null) _sc22.dispose();
  }

  final Map<ScrollController, bool> _doNotReissueJump = {};

  void _syncScrollControllers(ScrollController master, ScrollController slave) {
    // 마스터 컨트롤러에 리스너 추가
    masterListener() => _jumpToNoCascade(master, slave);
    master.addListener(masterListener);
    _listenersMap[master] = masterListener;

    // 슬레이브 컨트롤러에 리스너 추가
    slaveListener() => _jumpToNoCascade(slave, master);
    slave.addListener(slaveListener);
    _listenersMap[slave] = slaveListener;
  }

  void _jumpToNoCascade(ScrollController master, ScrollController slave) {
    if (!master.hasClients || !slave.hasClients || slave.position.outOfRange) {
      return;
    }

    if (_doNotReissueJump[master] == null ||
        _doNotReissueJump[master]! == false) {
      _doNotReissueJump[slave] = true;
      slave.jumpTo(master.offset);
    } else {
      _doNotReissueJump[master] = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _sc11!,
        _sc12,
        _sc21!,
        _sc22,
      );
}

```
## lib/src/widgets/tree_view.dart
```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/tree_node.dart';
import '../models/tree_view_theme.dart';
import '../utils/tree_view_width_calculator.dart';
import 'custom_inkwell.dart';
import 'synced_scroll_controllers.dart';

/// TreeView에서 사용하는 플랫화된 노드 정보
class _FlattenedNode {
  final TreeNode node;
  final int depth;

  _FlattenedNode({required this.node, required this.depth});
}

class TreeView extends StatefulWidget {
  final List<TreeNode> rootNodes;
  final Function(Account)? onAccountDoubleClick;
  final Function(Account)? onAccountRightClick;
  final Function(TreeNode)? onNodeTap;
  final Function(TreeNode)? onNodeDoubleClick;
  final Function(TreeNode)? onNodeRightClick;
  final TreeViewThemeData? theme;
  final String? selectedNodeId;
  final Function(String?)? onSelectionChanged;

  const TreeView({
    super.key,
    required this.rootNodes,
    this.onAccountDoubleClick,
    this.onAccountRightClick,
    this.onNodeTap,
    this.onNodeDoubleClick,
    this.onNodeRightClick,
    this.theme,
    this.selectedNodeId,
    this.onSelectionChanged,
  });

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> with TickerProviderStateMixin {
  final Map<String, bool> _expandedNodes = {};
  final Map<String, AnimationController> _expansionControllers = {};
  late TreeViewWidthCalculator _widthCalculator;
  bool _isHovered = false;

  /// 현재 사용할 테마
  TreeViewThemeData get _currentTheme =>
      widget.theme ?? TreeViewThemeData.defaultTheme();

  @override
  void initState() {
    super.initState();
    _initializeExpandedStates(widget.rootNodes);
    _widthCalculator = TreeViewWidthCalculator(theme: _currentTheme);
  }

  @override
  void didUpdateWidget(TreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) {
      _widthCalculator = TreeViewWidthCalculator(theme: _currentTheme);
    }
    if (widget.rootNodes != oldWidget.rootNodes) {
      _initializeExpandedStates(widget.rootNodes);
    }
  }

  @override
  void dispose() {
    // 모든 애니메이션 컨트롤러 dispose
    for (var controller in _expansionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeExpandedStates(List<TreeNode> nodes) {
    for (var node in nodes) {
      if (node is Folder || node is Node) {
        // 노드의 초기 확장 상태를 TreeNodeState에서 가져와서 적용
        _expandedNodes[node.id] ??= node.data.isExpanded;

        // 애니메이션 컨트롤러 생성
        if (!_expansionControllers.containsKey(node.id)) {
          final controller = AnimationController(
            duration: _currentTheme.expansionAnimationDuration,
            vsync: this,
          );
          if (_expandedNodes[node.id] ?? false) {
            controller.value = 1.0;
          }
          _expansionControllers[node.id] = controller;
        }

        if (node.children.isNotEmpty) {
          _initializeExpandedStates(node.children.cast<TreeNode>());
        }
      }
    }
  }

  void _toggleExpansion(String nodeId) {
    setState(() {
      final isExpanded = _expandedNodes[nodeId] ?? false;
      _expandedNodes[nodeId] = !isExpanded;

      final controller = _expansionControllers[nodeId];
      if (controller != null) {
        if (!isExpanded) {
          controller.forward();
        } else {
          controller.reverse();
        }
      }
    });
  }

  void _handleNodeSelection(TreeNode node) {
    if (node.data.isEnabled) {
      widget.onSelectionChanged?.call(node.id);
      widget.onNodeTap?.call(node);
    }
  }

  /// 플랫화된 노드 리스트 생성 (현재 표시되는 노드들만)
  List<_FlattenedNode> _getFlattenedNodes() {
    final List<_FlattenedNode> flattened = [];

    void traverse(List<TreeNode> nodes, int depth) {
      for (var node in nodes) {
        if (node.data.isVisible) {
          flattened.add(_FlattenedNode(node: node, depth: depth));

          if ((node is Folder || node is Node) &&
              node.children.isNotEmpty &&
              (_expandedNodes[node.id] ?? false)) {
            traverse(node.children.cast<TreeNode>(), depth + 1);
          }
        }
      }
    }

    traverse(widget.rootNodes, 0);
    return flattened;
  }

  /// 현재 표시되는 콘텐츠의 너비 계산
  double _calculateCurrentContentWidth() {
    return _widthCalculator.calculateVisibleContentWidth(
      widget.rootNodes,
      _expandedNodes,
    );
  }

  /// 전체 콘텐츠 높이 계산
  double _calculateContentHeight() {
    final flattenedNodes = _getFlattenedNodes();
    return flattenedNodes.length * _currentTheme.nodeMinHeight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = _currentTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // 콘텐츠 크기 계산
        final double contentWidth = math.max(
          _calculateCurrentContentWidth(),
          availableWidth,
        );
        final double contentHeight = _calculateContentHeight();

        // 스크롤 필요 여부
        final bool needsVerticalScroll = contentHeight > availableHeight;
        final bool needsHorizontalScroll = contentWidth > availableWidth;

        return Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            border: Border.all(
              color: theme.getEffectiveBorderColor(context),
              width: theme.borderWidth,
            ),
            borderRadius: theme.borderRadius,
          ),
          child: SyncedScrollControllers(
            builder: (
              context,
              verticalController,
              verticalScrollbarController,
              horizontalController,
              horizontalScrollbarController,
            ) {
              return MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                  ),
                  child: Stack(
                    children: [
                      // 메인 스크롤 영역
                      SingleChildScrollView(
                        controller: horizontalController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: contentWidth,
                          child: ListView.builder(
                            controller: verticalController,
                            itemCount: _getFlattenedNodes().length,
                            itemBuilder: (context, index) {
                              final flattenedNode = _getFlattenedNodes()[index];
                              return _buildTreeNode(
                                flattenedNode.node,
                                flattenedNode.depth,
                              );
                            },
                          ),
                        ),
                      ),

                      // 세로 스크롤바
                      if (theme.showVerticalScrollbar && needsVerticalScroll)
                        _buildVerticalScrollbar(
                          verticalScrollbarController,
                          availableHeight,
                          contentHeight,
                          needsHorizontalScroll,
                          theme,
                        ),

                      // 가로 스크롤바
                      if (theme.showHorizontalScrollbar &&
                          needsHorizontalScroll)
                        _buildHorizontalScrollbar(
                          horizontalScrollbarController,
                          availableWidth,
                          contentWidth,
                          theme,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 개선된 세로 스크롤바
  Widget _buildVerticalScrollbar(
    ScrollController controller,
    double availableHeight,
    double contentHeight,
    bool needsHorizontalScroll,
    TreeViewThemeData theme,
  ) {
    return Positioned(
      top: 0,
      right: 0,
      bottom: needsHorizontalScroll ? theme.scrollbarWidth : 0,
      child: AnimatedOpacity(
        opacity: theme.scrollbarHoverOnly
            ? (_isHovered ? theme.scrollbarHoverOpacity : 0.0)
            : theme.scrollbarOpacity,
        duration: theme.hoverAnimationDuration,
        child: Container(
          width: theme.scrollbarWidth,
          decoration: BoxDecoration(
            color: theme.scrollbarTrackColor,
            borderRadius: BorderRadius.circular(theme.scrollbarWidth / 2),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(theme.scrollbarColor),
                trackColor: WidgetStateProperty.all(Colors.transparent),
                radius: Radius.circular(theme.scrollbarWidth / 2),
                thickness: WidgetStateProperty.all(theme.scrollbarWidth - 4),
              ),
            ),
            child: Scrollbar(
              controller: controller,
              thumbVisibility: true,
              trackVisibility: false,
              child: SingleChildScrollView(
                controller: controller,
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  height: contentHeight,
                  width: theme.scrollbarWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 개선된 가로 스크롤바
  Widget _buildHorizontalScrollbar(
    ScrollController controller,
    double availableWidth,
    double contentWidth,
    TreeViewThemeData theme,
  ) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedOpacity(
        opacity: theme.scrollbarHoverOnly
            ? (_isHovered ? theme.scrollbarHoverOpacity : 0.0)
            : theme.scrollbarOpacity,
        duration: theme.hoverAnimationDuration,
        child: Container(
          height: theme.scrollbarWidth,
          decoration: BoxDecoration(
            color: theme.scrollbarTrackColor,
            borderRadius: BorderRadius.circular(theme.scrollbarWidth / 2),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(theme.scrollbarColor),
                trackColor: WidgetStateProperty.all(Colors.transparent),
                radius: Radius.circular(theme.scrollbarWidth / 2),
                thickness: WidgetStateProperty.all(theme.scrollbarWidth - 4),
              ),
            ),
            child: Scrollbar(
              controller: controller,
              thumbVisibility: true,
              trackVisibility: false,
              child: SingleChildScrollView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: contentWidth,
                  height: theme.scrollbarWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// TreeNode 타입에 따른 위젯 빌드
  Widget _buildTreeNode(TreeNode node, int depth) {
    if (node is Folder) {
      return _buildFolderNode(node, depth);
    } else if (node is Node) {
      return _buildNodeItem(node, depth);
    } else if (node is Account) {
      return _buildAccountItem(node, depth);
    }
    return const SizedBox.shrink();
  }

  /// 노드 상태에 따른 색상 계산
  Color? _getNodeBackgroundColor(TreeNode node) {
    final theme = _currentTheme;

    if (!node.data.isEnabled) {
      return theme.getEffectiveNodeDisabledColor(context);
    }

    if (widget.selectedNodeId == node.id) {
      return theme.getEffectiveNodeSelectedColor(context);
    }

    return null;
  }

  /// 노드 상태에 따른 텍스트 스타일 계산
  TextStyle _getNodeTextStyle(TreeNode node, TextStyle baseStyle) {
    final theme = _currentTheme;

    if (!node.data.isEnabled) {
      return theme.disabledTextStyle;
    }

    if (widget.selectedNodeId == node.id) {
      return theme.selectedTextStyle;
    }

    return baseStyle;
  }

  /// 확장 가능한 아이템 레이아웃 (hover와 선택 영역 일치)
  Widget _buildExpandableItemLayout({
    required TreeNode node,
    required int depth,
    required Widget arrowIcon,
    required Widget mainIcon,
    required String text,
    required TextStyle textStyle,
    VoidCallback? onTap,
  }) {
    final theme = _currentTheme;
    final indent = theme.indentSize * depth;
    final isSelected = widget.selectedNodeId == node.id;
    final isEnabled = node.data.isEnabled;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        constraints: BoxConstraints(minHeight: theme.nodeMinHeight),
        padding: EdgeInsets.symmetric(
          horizontal: theme.nodeHorizontalPadding,
          vertical: theme.nodeVerticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20.0,
              child: arrowIcon,
            ),
            Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: CustomInkwell(
                onTap: isEnabled
                    ? () {
                        _handleNodeSelection(node);
                        onTap?.call();
                      }
                    : null,
                borderRadius: theme.nodeBorderRadius,
                hoverColor: theme.enableHoverEffects
                    ? theme.getEffectiveNodeHoverColor(context)
                    : null,
                splashColor: theme.enableRippleEffects
                    ? theme.getEffectiveRippleColor(context)
                    : null,
                child: AnimatedContainer(
                  duration: theme.hoverAnimationDuration,
                  decoration: BoxDecoration(
                    color: _getNodeBackgroundColor(node), // 선택된 배경색을 여기로 이동
                    borderRadius: theme.nodeBorderRadius,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: theme.nodeSpacing,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      mainIcon,
                      SizedBox(width: theme.iconSpacing),
                      Text(
                        text,
                        style: _getNodeTextStyle(node, textStyle),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Account 아이템 레이아웃 (hover와 선택 영역 일치)
  Widget _buildAccountItemLayout({
    required TreeNode node,
    required int depth,
    required Widget mainIcon,
    required String text,
    required TextStyle textStyle,
    VoidCallback? onDoubleTap,
    VoidCallback? onRightClick,
  }) {
    final theme = _currentTheme;
    final indent = theme.indentSize * depth;
    final isEnabled = node.data.isEnabled;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        constraints: BoxConstraints(minHeight: theme.nodeMinHeight),
        padding: EdgeInsets.symmetric(
          horizontal: theme.nodeHorizontalPadding,
          vertical: theme.nodeVerticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20.0),
            Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: CustomInkwell(
                onDoubleTap: isEnabled
                    ? () {
                        if (node is Account) {
                          widget.onAccountDoubleClick?.call(node);
                        }
                        onDoubleTap?.call();
                      }
                    : null,
                onRightClick: isEnabled
                    ? () {
                        if (node is Account) {
                          widget.onAccountRightClick?.call(node);
                        }
                        onRightClick?.call();
                      }
                    : null,
                onTap: isEnabled ? () => _handleNodeSelection(node) : null,
                borderRadius: theme.nodeBorderRadius,
                hoverColor: theme.enableHoverEffects
                    ? theme.getEffectiveNodeHoverColor(context)
                    : null,
                splashColor: theme.enableRippleEffects
                    ? theme.getEffectiveRippleColor(context)
                    : null,
                child: AnimatedContainer(
                  duration: theme.hoverAnimationDuration,
                  decoration: BoxDecoration(
                    color: _getNodeBackgroundColor(node), // 선택된 배경색을 여기로 이동
                    borderRadius: theme.nodeBorderRadius,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: theme.nodeSpacing,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      mainIcon,
                      SizedBox(width: theme.iconSpacing),
                      Text(
                        text,
                        style: _getNodeTextStyle(node, textStyle),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 폴더 노드 빌드 (완전히 테마 적용)
  Widget _buildFolderNode(Folder folder, int depth) {
    final theme = _currentTheme;
    final isExpanded = _expandedNodes[folder.id] ?? false;
    final controller = _expansionControllers[folder.id];

    return _buildExpandableItemLayout(
      node: folder,
      depth: depth,
      arrowIcon: controller != null
          ? RotationTransition(
              turns: Tween(begin: 0.0, end: 0.25).animate(
                CurvedAnimation(
                  parent: controller,
                  curve: theme.expansionCurve,
                ),
              ),
              child: Icon(
                Icons.keyboard_arrow_right,
                size: 16,
                color: folder.data.isEnabled
                    ? theme.arrowColor
                    : theme.disabledIconColor,
              ),
            )
          : Icon(
              Icons.keyboard_arrow_right,
              size: 16,
              color: folder.data.isEnabled
                  ? theme.arrowColor
                  : theme.disabledIconColor,
            ),
      mainIcon: Icon(
        isExpanded ? Icons.folder_open : Icons.folder,
        color: folder.data.isEnabled
            ? (isExpanded ? theme.folderExpandedColor : theme.folderColor)
            : theme.disabledIconColor,
        size: theme.iconSize,
      ),
      text: folder.name,
      textStyle: theme.folderTextStyle,
      onTap: folder.data.isEnabled ? () => _toggleExpansion(folder.id) : null,
    );
  }

  /// 노드 아이템 빌드 (완전히 테마 적용)
  Widget _buildNodeItem(Node node, int depth) {
    final theme = _currentTheme;
    final isExpanded = _expandedNodes[node.id] ?? false;
    final controller = _expansionControllers[node.id];

    return _buildExpandableItemLayout(
      node: node,
      depth: depth,
      arrowIcon: controller != null
          ? RotationTransition(
              turns: Tween(begin: 0.0, end: 0.25).animate(
                CurvedAnimation(
                  parent: controller,
                  curve: theme.expansionCurve,
                ),
              ),
              child: Icon(
                Icons.keyboard_arrow_right,
                size: 16,
                color: node.data.isEnabled
                    ? theme.arrowColor
                    : theme.disabledIconColor,
              ),
            )
          : Icon(
              Icons.keyboard_arrow_right,
              size: 16,
              color: node.data.isEnabled
                  ? theme.arrowColor
                  : theme.disabledIconColor,
            ),
      mainIcon: Icon(
        isExpanded ? Icons.dns : Icons.storage,
        color: node.data.isEnabled
            ? (isExpanded ? theme.nodeExpandedColor : theme.nodeColor)
            : theme.disabledIconColor,
        size: theme.iconSize,
      ),
      text: node.name,
      textStyle: theme.nodeTextStyle,
      onTap: node.data.isEnabled ? () => _toggleExpansion(node.id) : null,
    );
  }

  /// Account 아이템 빌드 (완전히 테마 적용)
  Widget _buildAccountItem(Account account, int depth) {
    final theme = _currentTheme;

    return _buildAccountItemLayout(
      node: account,
      depth: depth,
      mainIcon: Icon(
        Icons.account_circle,
        color: account.data.isEnabled
            ? theme.accountColor
            : theme.disabledIconColor,
        size: theme.iconSize,
      ),
      text: account.name,
      textStyle: theme.accountTextStyle,
      onDoubleTap: () => widget.onAccountDoubleClick?.call(account),
      onRightClick: () => widget.onAccountRightClick?.call(account),
    );
  }
}

```
## pubspec.yaml
```yaml
name: flutter_basic_folderview
description: "A new Flutter package project."
version: 0.0.1
homepage:

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # To add assets to your package, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg
  #
  # For details regarding assets in packages, see
  # https://flutter.dev/to/asset-from-package
  #
  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # To add custom fonts to your package, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts in packages, see
  # https://flutter.dev/to/font-from-package

```
