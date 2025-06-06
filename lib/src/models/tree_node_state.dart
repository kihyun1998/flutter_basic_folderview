class TreeNodeState {
  final bool isSelected;
  final bool isExpanded;
  final String status;
  final dynamic metadata; // Map, String, int, 커스텀 객체 등 무엇이든 가능

  TreeNodeState({
    this.isSelected = false,
    this.isExpanded = false,
    this.status = 'normal',
    this.metadata,
  });

  factory TreeNodeState.init() {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      status: 'normal',
      metadata: null,
    );
  }

  // 편의를 위한 추가 팩토리들
  factory TreeNodeState.withMetadata(dynamic metadata) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      status: 'normal',
      metadata: metadata,
    );
  }

  factory TreeNodeState.withStringMetadata(String metadata) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      status: 'normal',
      metadata: metadata,
    );
  }

  factory TreeNodeState.withMapMetadata(Map<String, dynamic> metadata) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      status: 'normal',
      metadata: metadata,
    );
  }

  factory TreeNodeState.withIntMetadata(int metadata) {
    return TreeNodeState(
      isSelected: false,
      isExpanded: false,
      status: 'normal',
      metadata: metadata,
    );
  }

  TreeNodeState copyWith({
    bool? isSelected,
    bool? isExpanded,
    String? status,
    dynamic metadata,
  }) {
    return TreeNodeState(
      isSelected: isSelected ?? this.isSelected,
      isExpanded: isExpanded ?? this.isExpanded,
      status: status ?? this.status,
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
    return 'TreeNodeState(isSelected: $isSelected, isExpanded: $isExpanded, status: $status, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TreeNodeState &&
        other.isSelected == isSelected &&
        other.isExpanded == isExpanded &&
        other.status == status &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return isSelected.hashCode ^
        isExpanded.hashCode ^
        status.hashCode ^
        metadata.hashCode;
  }
}
