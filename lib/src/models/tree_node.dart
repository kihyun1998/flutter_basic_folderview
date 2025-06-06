import 'tree_node_state.dart';

abstract class TreeNode<T> {
  final String id;
  final String name;
  final List<dynamic> children;
  final T data;

  TreeNode({
    required this.id,
    required this.name,
    List<dynamic>? children,
    required this.data,
  }) : children = children ?? [];

  TreeNode<T> copyWith({
    String? id,
    String? name,
    List<dynamic>? children,
    T? data,
  });
}

class Node extends TreeNode<TreeNodeState> {
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

class Account extends TreeNode<TreeNodeState> {
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

class Folder extends TreeNode<bool> {
  Folder({
    required super.id,
    required super.name,
    super.children,
    super.data = false,
  });

  factory Folder.init() => Folder(id: "", name: "");

  @override
  Folder copyWith({
    String? id,
    String? name,
    List<dynamic>? children,
    bool? data,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      children: children ?? this.children,
      data: data ?? this.data,
    );
  }
}
