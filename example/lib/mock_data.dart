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
