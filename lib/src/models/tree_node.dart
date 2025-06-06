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
