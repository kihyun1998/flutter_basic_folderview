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
