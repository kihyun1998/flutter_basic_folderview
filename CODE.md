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
    // 새로운 dynamic metadata 기능 시연
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

```
## example/lib/mock_data.dart
```dart
import 'package:flutter_basic_folderview/flutter_basic_folderview.dart';

// 커스텀 메타데이터 클래스 예제들
class UserInfo {
  final String name;
  final int id;
  final String role;
  final DateTime lastLogin;

  UserInfo({
    required this.name,
    required this.id,
    required this.role,
    required this.lastLogin,
  });

  @override
  String toString() => 'UserInfo(name: $name, id: $id, role: $role)';
}

class ServerInfo {
  final String host;
  final int port;
  final String status;
  final double cpuUsage;

  ServerInfo({
    required this.host,
    required this.port,
    required this.status,
    required this.cpuUsage,
  });

  @override
  String toString() =>
      'ServerInfo(host: $host:$port, status: $status, cpu: $cpuUsage%)';
}

class MockData {
  static List<TreeNode> createTestData() {
    // 다양한 타입의 메타데이터 사용 예제

    // 1. String 메타데이터를 가진 Account들
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

    // 2. 커스텀 객체 메타데이터를 가진 Account들
    final account3 = Account(
      id: 'acc_3',
      name: 'guest@domain.com',
      data: TreeNodeState.withMetadata(UserInfo(
        name: 'Guest User',
        id: 789,
        role: 'guest',
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
      )),
    );

    final account4 = Account(
      id: 'acc_4',
      name: 'test@domain.com',
      data: TreeNodeState.withMetadata(UserInfo(
        name: 'Test User',
        id: 101,
        role: 'tester',
        lastLogin: DateTime.now(),
      )),
    );

    // 3. Map 메타데이터를 가진 Account들
    final account5 = Account(
      id: 'acc_5',
      name: 'manager@domain.com',
      data: TreeNodeState.withMapMetadata({
        'department': 'Engineering',
        'level': 'Senior',
        'projects': ['ProjectA', 'ProjectB'],
        'budget': 50000,
      }),
    );

    final account6 = Account(
      id: 'acc_6',
      name: 'intern@domain.com',
      data: TreeNodeState.withIntMetadata(2024), // 입사 연도
    );

    // 4. 서버 정보를 메타데이터로 가진 Node들
    final node1 = Node(
      id: 'node_1',
      name: 'Web Server',
      children: [account1, account2],
      data: TreeNodeState.withMetadata(ServerInfo(
        host: '192.168.1.10',
        port: 80,
        status: 'running',
        cpuUsage: 25.5,
      )),
    );

    final node2 = Node(
      id: 'node_2',
      name: 'Database Server',
      children: [account3],
      data: TreeNodeState.withMetadata(ServerInfo(
        host: '192.168.1.20',
        port: 5432,
        status: 'running',
        cpuUsage: 78.3,
      )),
    );

    // 5. 간단한 String 메타데이터를 가진 Node
    final node3 = Node(
      id: 'node_3',
      name: 'API Server',
      children: [account4],
      data: TreeNodeState.withStringMetadata("api_v2.1.0"),
    );

    final node4 = Node(
      id: 'node_4',
      name: 'Cache Server',
      children: [account5, account6],
      data: TreeNodeState.withMapMetadata({
        'type': 'Redis',
        'version': '7.0.5',
        'memory_usage': '2.3GB',
        'hit_ratio': 0.95,
      }),
    );

    // 6. 폴더들 (새로운 TreeNodeState 기반)
    final subFolder = Folder.create(
      id: 'folder_sub',
      name: 'Development',
      children: [node3],
      metadata: 'development_environment', // String 메타데이터
    );

    final folder1 = Folder.create(
      id: 'folder_1',
      name: 'Production',
      children: [node1, node2],
      metadata: {
        'environment': 'production',
        'region': 'us-east-1',
        'criticality': 'high',
      }, // Map 메타데이터
    );

    final folder2 = Folder.create(
      id: 'folder_2',
      name: 'Staging',
      children: [subFolder],
      metadata: {
        'environment': 'staging',
        'auto_deploy': true,
        'test_coverage': 85.5,
      }, // Map 메타데이터
    );

    return [folder1, folder2, node4];
  }

  // 더 복잡한 테스트 데이터
  static List<TreeNode> createComplexTestData() {
    final List<TreeNode> nodes = [];

    // 대용량 테스트를 위한 데이터 (다양한 메타데이터 타입 사용)
    for (int i = 0; i < 3; i++) {
      final folder = Folder.create(
        id: 'root_folder_$i',
        name: 'Root Folder $i',
        metadata: {
          'level': 'root',
          'index': i,
          'created': DateTime.now().subtract(Duration(days: i)),
        },
      );

      for (int j = 0; j < 2; j++) {
        final subFolder = Folder.create(
          id: 'sub_folder_${i}_$j',
          name: 'Sub Folder $j',
          metadata: 'sub_level_${i}_$j', // String 메타데이터
        );

        for (int k = 0; k < 3; k++) {
          // 서버 노드에 ServerInfo 메타데이터
          final node = Node(
            id: 'node_${i}_${j}_$k',
            name: 'Server $i-$j-$k',
            data: TreeNodeState.withMetadata(ServerInfo(
              host: '192.168.$i.$k',
              port: 8000 + k,
              status: k % 2 == 0 ? 'running' : 'stopped',
              cpuUsage: (k + 1) * 20.0 + i * 5,
            )),
          );

          for (int l = 0; l < 2; l++) {
            // 계정에 UserInfo 메타데이터
            final account = Account(
              id: 'acc_${i}_${j}_${k}_$l',
              name: 'user$l@server$k.com',
              data: TreeNodeState.withMetadata(UserInfo(
                name: 'User $i-$j-$k-$l',
                id: i * 1000 + j * 100 + k * 10 + l,
                role: l == 0 ? 'admin' : 'user',
                lastLogin: DateTime.now().subtract(Duration(hours: l + k)),
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

  // 메타데이터 사용 예제를 위한 헬퍼 메서드들
  static void demonstrateMetadataUsage(List<TreeNode> nodes) {
    print('=== 메타데이터 사용 예제 ===');

    void printNodeMetadata(TreeNode node, int depth) {
      final indent = '  ' * depth;
      print('$indent${node.name} (${node.runtimeType})');

      if (node is Account || node is Node) {
        final state = node.data;
        final metadata = state.metadata;

        if (metadata != null) {
          print('$indent  └─ 메타데이터: ${metadata.runtimeType}');

          // 타입별로 다른 접근 방법 시연
          if (metadata is String) {
            print('$indent     String: "$metadata"');
          } else if (metadata is UserInfo) {
            print('$indent     UserInfo: ${metadata.name} (${metadata.role})');
          } else if (metadata is ServerInfo) {
            print(
                '$indent     ServerInfo: ${metadata.host}:${metadata.port} (${metadata.status})');
          } else if (metadata is Map) {
            print('$indent     Map: ${metadata.keys.join(', ')}');
          } else if (metadata is int) {
            print('$indent     Int: $metadata');
          }

          // 헬퍼 메서드 사용 예제
          final asString = state.metadataAsString;
          final asUserInfo = state.getMetadataAs<UserInfo>();
          final asServerInfo = state.getMetadataAs<ServerInfo>();

          if (asUserInfo != null) {
            print(
                '$indent     └─ 안전한 접근: ${asUserInfo.name} (${asUserInfo.role})');
          } else if (asServerInfo != null) {
            print(
                '$indent     └─ 안전한 접근: ${asServerInfo.host} (CPU: ${asServerInfo.cpuUsage}%)');
          } else if (asString != null) {
            print('$indent     └─ 문자열로: "$asString"');
          }
        } else {
          print('$indent  └─ 메타데이터: null');
        }
      }

      // 자식 노드들도 순회
      for (final child in node.children) {
        if (child is TreeNode) {
          printNodeMetadata(child, depth + 1);
        }
      }
    }

    for (final node in nodes) {
      printNodeMetadata(node, 0);
    }
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

/// 간소화된 TreeView 테마 데이터
class TreeViewThemeData {
  // 스크롤바 설정
  final bool showVerticalScrollbar;
  final bool showHorizontalScrollbar;
  final double scrollbarWidth;
  final Color scrollbarColor;
  final Color scrollbarTrackColor;
  final bool scrollbarHoverOnly;

  // 노드 스타일
  final double nodeVerticalPadding;
  final double nodeHorizontalPadding;
  final double iconSize;
  final double iconSpacing;
  final BorderRadius nodeBorderRadius;
  final Color? nodeHoverColor;

  // 아이콘 색상
  final Color folderColor;
  final Color nodeColor;
  final Color accountColor;
  final Color arrowColor;

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

  const TreeViewThemeData({
    // 스크롤바 기본값
    this.showVerticalScrollbar = true,
    this.showHorizontalScrollbar = true,
    this.scrollbarWidth = 12.0,
    this.scrollbarColor = const Color(0xFF757575),
    this.scrollbarTrackColor = const Color(0x1A000000),
    this.scrollbarHoverOnly = true,

    // 노드 스타일 기본값
    this.nodeVerticalPadding = 4.0,
    this.nodeHorizontalPadding = 8.0,
    this.iconSize = 20.0,
    this.iconSpacing = 8.0,
    this.nodeBorderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.nodeHoverColor,

    // 아이콘 색상 기본값
    this.folderColor = const Color(0xFFFFB300),
    this.nodeColor = const Color(0xFF1976D2),
    this.accountColor = const Color(0xFF388E3C),
    this.arrowColor = const Color(0xFF757575),

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
  });

  /// 기본 테마 생성
  factory TreeViewThemeData.defaultTheme() {
    return const TreeViewThemeData();
  }

  TreeViewThemeData copyWith({
    bool? showVerticalScrollbar,
    bool? showHorizontalScrollbar,
    double? scrollbarWidth,
    Color? scrollbarColor,
    Color? scrollbarTrackColor,
    bool? scrollbarHoverOnly,
    double? nodeVerticalPadding,
    double? nodeHorizontalPadding,
    double? iconSize,
    double? iconSpacing,
    BorderRadius? nodeBorderRadius,
    Color? nodeHoverColor,
    Color? folderColor,
    Color? nodeColor,
    Color? accountColor,
    Color? arrowColor,
    double? indentSize,
    double? nodeSpacing,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    TextStyle? folderTextStyle,
    TextStyle? nodeTextStyle,
    TextStyle? accountTextStyle,
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
      nodeVerticalPadding: nodeVerticalPadding ?? this.nodeVerticalPadding,
      nodeHorizontalPadding:
          nodeHorizontalPadding ?? this.nodeHorizontalPadding,
      iconSize: iconSize ?? this.iconSize,
      iconSpacing: iconSpacing ?? this.iconSpacing,
      nodeBorderRadius: nodeBorderRadius ?? this.nodeBorderRadius,
      nodeHoverColor: nodeHoverColor ?? this.nodeHoverColor,
      folderColor: folderColor ?? this.folderColor,
      nodeColor: nodeColor ?? this.nodeColor,
      accountColor: accountColor ?? this.accountColor,
      arrowColor: arrowColor ?? this.arrowColor,
      indentSize: indentSize ?? this.indentSize,
      nodeSpacing: nodeSpacing ?? this.nodeSpacing,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      folderTextStyle: folderTextStyle ?? this.folderTextStyle,
      nodeTextStyle: nodeTextStyle ?? this.nodeTextStyle,
      accountTextStyle: accountTextStyle ?? this.accountTextStyle,
    );
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
  final TreeViewThemeData? theme;

  const TreeView({
    super.key,
    required this.rootNodes,
    this.onAccountDoubleClick,
    this.onAccountRightClick,
    this.theme,
  });

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  final Map<String, bool> _expandedNodes = {};
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

  void _initializeExpandedStates(List<TreeNode> nodes) {
    for (var node in nodes) {
      if (node is Folder || node is Node) {
        // 노드의 초기 확장 상태를 TreeNodeState에서 가져와서 적용
        // 하지만 _expandedNodes가 이미 설정되어 있다면 그것을 우선시
        _expandedNodes[node.id] ??= node.data.isExpanded;

        if (node.children.isNotEmpty) {
          _initializeExpandedStates(node.children.cast<TreeNode>());
        }
      }
    }
  }

  void _toggleExpansion(String nodeId) {
    setState(() {
      _expandedNodes[nodeId] = !(_expandedNodes[nodeId] ?? false);
    });
  }

  /// 플랫화된 노드 리스트 생성 (현재 표시되는 노드들만)
  List<_FlattenedNode> _getFlattenedNodes() {
    final List<_FlattenedNode> flattened = [];

    void traverse(List<TreeNode> nodes, int depth) {
      for (var node in nodes) {
        flattened.add(_FlattenedNode(node: node, depth: depth));

        if ((node is Folder || node is Node) &&
            node.children.isNotEmpty &&
            (_expandedNodes[node.id] ?? false)) {
          traverse(node.children.cast<TreeNode>(), depth + 1);
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
    return flattenedNodes.length * _getNodeHeight();
  }

  /// 개별 노드의 높이
  double _getNodeHeight() {
    return _currentTheme.nodeVerticalPadding * 2 +
        _currentTheme.nodeSpacing * 2 +
        _currentTheme.iconSize;
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
              color: theme.borderColor ?? Colors.grey.shade300,
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
                  // Flutter 기본 스크롤바 숨기기
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

                      // 세로 스크롤바 (우측 오버레이)
                      if (theme.showVerticalScrollbar && needsVerticalScroll)
                        _buildVerticalScrollbar(
                          verticalScrollbarController,
                          availableHeight,
                          contentHeight,
                          needsHorizontalScroll,
                          theme,
                        ),

                      // 가로 스크롤바 (하단 오버레이)
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

  /// 세로 스크롤바 위젯 생성
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
        opacity: theme.scrollbarHoverOnly ? (_isHovered ? 0.7 : 0.0) : 0.7,
        duration: const Duration(milliseconds: 200),
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

  /// 가로 스크롤바 위젯 생성
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
        opacity: theme.scrollbarHoverOnly ? (_isHovered ? 0.7 : 0.0) : 0.7,
        duration: const Duration(milliseconds: 200),
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

  /// 확장 가능한 아이템 레이아웃
  Widget _buildExpandableItemLayout({
    required int depth,
    required Widget arrowIcon,
    required Widget mainIcon,
    required String text,
    required TextStyle textStyle,
    VoidCallback? onTap,
  }) {
    final theme = _currentTheme;
    final indent = theme.indentSize * depth;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.nodeHorizontalPadding,
          vertical: theme.nodeVerticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20.0, // 화살표 아이콘 너비 고정
              child: arrowIcon,
            ),
            CustomInkwell(
              onTap: onTap,
              borderRadius: theme.nodeBorderRadius,
              hoverColor: theme.nodeHoverColor,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: theme.nodeSpacing,
                  horizontal: 8.0, // 콘텐츠 패딩 고정
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    mainIcon,
                    SizedBox(width: theme.iconSpacing),
                    Text(text, style: textStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Account 아이템 레이아웃
  Widget _buildAccountItemLayout({
    required int depth,
    required Widget mainIcon,
    required String text,
    required TextStyle textStyle,
    VoidCallback? onDoubleTap,
    VoidCallback? onRightClick,
  }) {
    final theme = _currentTheme;
    final indent = theme.indentSize * depth;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.nodeHorizontalPadding,
          vertical: theme.nodeVerticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 20.0), // 화살표 아이콘 공간
            CustomInkwell(
              onDoubleTap: onDoubleTap,
              onRightClick: onRightClick,
              borderRadius: theme.nodeBorderRadius,
              hoverColor: theme.nodeHoverColor,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: theme.nodeSpacing,
                  horizontal: 8.0, // 콘텐츠 패딩 고정
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    mainIcon,
                    SizedBox(width: theme.iconSpacing),
                    Text(text, style: textStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 폴더 노드 빌드
  Widget _buildFolderNode(Folder folder, int depth) {
    final theme = _currentTheme;
    final isExpanded = _expandedNodes[folder.id] ?? false;

    return _buildExpandableItemLayout(
      depth: depth,
      arrowIcon: RotationTransition(
        turns: AlwaysStoppedAnimation(isExpanded ? 0.25 : 0.0),
        child: Icon(
          Icons.keyboard_arrow_right,
          size: 16,
          color: theme.arrowColor,
        ),
      ),
      mainIcon: Icon(
        isExpanded ? Icons.folder_open : Icons.folder,
        color: theme.folderColor,
        size: theme.iconSize,
      ),
      text: folder.name,
      textStyle: theme.folderTextStyle,
      onTap: () => _toggleExpansion(folder.id),
    );
  }

  /// 노드 아이템 빌드
  Widget _buildNodeItem(Node node, int depth) {
    final theme = _currentTheme;
    final isExpanded = _expandedNodes[node.id] ?? false;

    return _buildExpandableItemLayout(
      depth: depth,
      arrowIcon: RotationTransition(
        turns: AlwaysStoppedAnimation(isExpanded ? 0.25 : 0.0),
        child: Icon(
          Icons.keyboard_arrow_right,
          size: 16,
          color: theme.arrowColor,
        ),
      ),
      mainIcon: Icon(
        isExpanded ? Icons.dns : Icons.storage,
        color: theme.nodeColor,
        size: theme.iconSize,
      ),
      text: node.name,
      textStyle: theme.nodeTextStyle,
      onTap: () => _toggleExpansion(node.id),
    );
  }

  /// Account 아이템 빌드
  Widget _buildAccountItem(Account account, int depth) {
    final theme = _currentTheme;

    return _buildAccountItemLayout(
      depth: depth,
      mainIcon: Icon(
        Icons.account_circle,
        color: theme.accountColor,
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
