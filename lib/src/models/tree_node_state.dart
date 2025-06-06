class TreeNodeState {
  final bool isSelected;
  final bool isExpanded;
  final String status;
  final Map<String, dynamic> metadata;

  TreeNodeState({
    this.isSelected = false,
    this.isExpanded = false,
    this.status = 'normal',
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  factory TreeNodeState.init() {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      status: 'normal',
      metadata: {},
    );
  }

  // 사용자의 기존 코드에서 사용되는 fromPathUser 팩토리 (간단 버전)
  factory TreeNodeState.fromPathUser(dynamic pathUser) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      status: 'active',
      metadata: {
        'pathUser': pathUser.toString(),
      },
    );
  }

  TreeNodeState copyWith({
    bool? isSelected,
    bool? isExpanded,
    String? status,
    Map<String, dynamic>? metadata,
  }) {
    return TreeNodeState(
      isSelected: isSelected ?? this.isSelected,
      isExpanded: isExpanded ?? this.isExpanded,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'TreeNodeState(isSelected: $isSelected, isExpanded: $isExpanded, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TreeNodeState &&
        other.isSelected == isSelected &&
        other.isExpanded == isExpanded &&
        other.status == status;
  }

  @override
  int get hashCode {
    return isSelected.hashCode ^ isExpanded.hashCode ^ status.hashCode;
  }
}
