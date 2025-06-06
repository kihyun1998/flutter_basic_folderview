import 'package:flutter_basic_folderview/flutter_basic_folderview.dart';

class MockData {
  static List<TreeNode> createTestData() {
    // 테스트용 TreeNodeState 생성
    final nodeState1 = TreeNodeState.init();
    final nodeState2 = TreeNodeState.init();
    final nodeState3 = TreeNodeState.init();
    final nodeState4 = TreeNodeState.init();

    // Account들 생성
    final account1 = Account(
      id: 'acc_1',
      name: 'admin@example.com',
      data: nodeState1,
    );

    final account2 = Account(
      id: 'acc_2',
      name: 'user@example.com',
      data: nodeState1,
    );

    final account3 = Account(
      id: 'acc_3',
      name: 'guest@domain.com',
      data: nodeState2,
    );

    final account4 = Account(
      id: 'acc_4',
      name: 'test@domain.com',
      data: nodeState3,
    );

    final account5 = Account(
      id: 'acc_5',
      name: 'test@domain.com',
      data: nodeState4,
    );
    final account6 = Account(
      id: 'acc_6',
      name: 'test@domain.com',
      data: nodeState4,
    );

    // Node들 생성
    final node1 = Node(
      id: 'node_1',
      name: 'Web Server',
      children: [account1, account2],
      data: nodeState1,
    );

    final node2 = Node(
      id: 'node_2',
      name: 'Database Server',
      children: [account3],
      data: nodeState2,
    );

    final node3 = Node(
      id: 'node_3',
      name: 'API Server',
      children: [account4],
      data: nodeState3,
    );

    final node4 = Node(
      id: 'node_4',
      name: 'API Server',
      children: [account5, account6],
      data: nodeState3,
    );

    // 서브 폴더 생성
    final subFolder = Folder(
      id: 'folder_sub',
      name: 'Development',
      children: [node3],
      data: false,
    );

    // 루트 폴더들 생성
    final folder1 = Folder(
      id: 'folder_1',
      name: 'Production',
      children: [node1, node2],
      data: false,
    );

    final folder2 = Folder(
      id: 'folder_2',
      name: 'Staging',
      children: [subFolder],
      data: false,
    );

    // 혼합된 루트 노드들 반환 (Folder와 Node 모두 루트에 올 수 있다고 가정)
    return [folder1, folder2, node4];
  }

  // 더 복잡한 테스트 데이터
  static List<TreeNode> createComplexTestData() {
    final List<TreeNode> nodes = [];

    // 대용량 테스트를 위한 데이터
    for (int i = 0; i < 3; i++) {
      final folder = Folder(
        id: 'root_folder_$i',
        name: 'Root Folder $i',
        data: false,
      );

      for (int j = 0; j < 2; j++) {
        final subFolder = Folder(
          id: 'sub_folder_${i}_$j',
          name: 'Sub Folder $j',
          data: false,
        );

        for (int k = 0; k < 3; k++) {
          final node = Node(
            id: 'node_${i}_${j}_$k',
            name: 'Server $i-$j-$k',
            data: TreeNodeState.init(),
          );

          for (int l = 0; l < 2; l++) {
            final account = Account(
              id: 'acc_${i}_${j}_${k}_$l',
              name: 'user$l@server$k.com',
              data: TreeNodeState.init(),
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
}
